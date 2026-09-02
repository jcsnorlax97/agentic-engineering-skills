#!/usr/bin/env python3
"""Extract user/assistant text from a Claude Code session JSONL transcript, and
optionally split it into line-count chunks for parallel subagent review.

Used by improvement-extraction's "full-session sweep" mode. A raw session
transcript is mostly tool_result/attachment noise (often 20-50x the size of
the actual conversation text) — this strips that down to just what a human
or a review subagent actually needs to read: user/assistant message text,
with tool_use calls collapsed to a one-line signature and tool_results
truncated, thinking blocks dropped entirely.

Usage:
    python3 extract_transcript.py --session <path-to-.jsonl> --out <dir> [--chunk-lines N]

If --session is omitted, auto-detects the most-recently-modified .jsonl in
the Claude Code project directory for the current working directory
(~/.claude/projects/<encoded-cwd>/*.jsonl) — this is the active session
when run mid-conversation. Prints the resolved path so the caller can
confirm it picked the right one.

Output: <out>/session_text.txt (full extract), plus <out>/chunk_NN.txt files
if --chunk-lines is given (0 = no chunking, just the full extract).
"""
import argparse
import json
import os
import sys
import glob


def encode_cwd_for_project_dir(cwd: str) -> str:
    # Claude Code's project-dir encoding: replace path separators and a few
    # reserved characters with '-'. This mirrors what's observed in
    # ~/.claude/projects/ directory names; adjust here if that scheme changes.
    encoded = (
        cwd.replace("\\", "-")
        .replace("/", "-")
        .replace(":", "-")
        .replace(" ", "-")
        .replace(".", "-")
    )
    return encoded


def find_latest_session_jsonl() -> str:
    home = os.path.expanduser("~")
    projects_root = os.path.join(home, ".claude", "projects")
    cwd = os.getcwd()
    encoded = encode_cwd_for_project_dir(cwd)
    candidate_dir = os.path.join(projects_root, encoded)
    search_dirs = [candidate_dir] if os.path.isdir(candidate_dir) else []
    if not search_dirs:
        # Fall back to scanning all project dirs for the most recently
        # modified .jsonl anywhere — slower but works if the encoding
        # guess above is wrong.
        search_dirs = [d for d in glob.glob(os.path.join(projects_root, "*")) if os.path.isdir(d)]

    all_jsonl = []
    for d in search_dirs:
        all_jsonl.extend(glob.glob(os.path.join(d, "*.jsonl")))

    if not all_jsonl:
        raise FileNotFoundError(
            f"No session .jsonl found under {projects_root}. Pass --session explicitly."
        )

    all_jsonl.sort(key=os.path.getmtime, reverse=True)
    return all_jsonl[0]


def extract_text(content):
    if isinstance(content, str):
        return content
    parts = []
    if isinstance(content, list):
        for block in content:
            if not isinstance(block, dict):
                continue
            btype = block.get("type")
            if btype == "text":
                parts.append(block.get("text", ""))
            elif btype == "thinking":
                continue  # too verbose, not needed for review
            elif btype == "tool_use":
                name = block.get("name", "?")
                brief = str(block.get("input", {}))[:200]
                parts.append(f"[TOOL_USE {name}: {brief}]")
            elif btype == "tool_result":
                c = block.get("content", "")
                if isinstance(c, list):
                    c = " ".join(
                        x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text"
                    )
                parts.append(f"[TOOL_RESULT: {str(c)[:300]}]")
    return "\n".join(parts)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--session", help="Path to the session .jsonl. Auto-detected if omitted.")
    ap.add_argument("--out", required=True, help="Output directory (must already exist).")
    ap.add_argument(
        "--chunk-lines",
        type=int,
        default=0,
        help="Split into chunk_NN.txt files of this many lines each. 0 = no split.",
    )
    args = ap.parse_args()

    session_path = args.session or find_latest_session_jsonl()
    print(f"Reading session: {session_path}", file=sys.stderr)

    os.makedirs(args.out, exist_ok=True)
    out_path = os.path.join(args.out, "session_text.txt")
    count = 0
    with open(session_path, encoding="utf-8", errors="replace") as f, \
         open(out_path, "w", encoding="utf-8") as out:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:
                continue
            t = obj.get("type")
            if t not in ("user", "assistant"):
                continue
            msg = obj.get("message", obj)
            role = msg.get("role", t)
            text = extract_text(msg.get("content", ""))
            if not text.strip():
                continue
            out.write(f"=== {role.upper()} ===\n{text}\n\n")
            count += 1

    size = os.path.getsize(out_path)
    print(f"Wrote {count} messages ({size:,} bytes) to {out_path}", file=sys.stderr)

    if args.chunk_lines and args.chunk_lines > 0:
        with open(out_path, encoding="utf-8") as f:
            lines = f.readlines()
        n_chunks = max(1, (len(lines) + args.chunk_lines - 1) // args.chunk_lines)
        chunk_paths = []
        for i in range(n_chunks):
            chunk_lines = lines[i * args.chunk_lines: (i + 1) * args.chunk_lines]
            chunk_path = os.path.join(args.out, f"chunk_{i:02d}.txt")
            with open(chunk_path, "w", encoding="utf-8") as cf:
                cf.writelines(chunk_lines)
            chunk_paths.append(chunk_path)
        print(f"Split into {n_chunks} chunk files ({args.chunk_lines} lines each) in {args.out}:", file=sys.stderr)
        for p in chunk_paths:
            print(f"  {p}", file=sys.stderr)


if __name__ == "__main__":
    main()
