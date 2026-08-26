# Python Conventions Baseline

Status: active
Version: 0.1.0

Always-on Python correctness rules for scripts and one-liners that must
behave the same way across operating systems (Windows, macOS, Linux),
console encodings, and the CLI tools they drive. Distilled from four 2026-08
incident notes captured during Azure DevOps scripting and tool-output
processing work, where Python's own platform-specific string, encoding, and
library behavior silently mangled a path, a parse, or persisted text without
raising an error until much later, if ever.

## Principles

1. Whenever a Windows filesystem path is interpolated into a Python
   one-liner's string literal, use a raw string (`r'...'`) or forward
   slashes — never a plain quoted literal.
   Code like `python -c "open('C:\Users\name\file.txt')"` compiles and runs
   without error, because backslash-U and backslash-n-ish sequences get
   silently read as escape sequences inside an ordinary quoted string, not as
   literal path separators. The failure mode is not a clean exception in
   every case — `\U` and `\N` raise, but `\n`, `\t`, `\a`, and similar
   sequences in a real path silently corrupt the string into something that
   looks plausible and points at the wrong file. Use `r'C:\Users\name\file.txt'`
   or `'C:/Users/name/file.txt'` instead; both are read literally by Windows
   APIs. This applies to any interpolated path, not just command-line
   one-liners, but one-liners are where it bites hardest because there is no
   linter or IDE warning in the loop.

2. When a saved large JSON tool-output file fails a whole-file `json.load()`
   with an "Extra data" error, use `json.JSONDecoder().raw_decode()` to parse
   just the first valid JSON object instead of assuming the file is
   corrupt.
   Many CLI tools and logging wrappers append trailing non-JSON data after a
   valid JSON object — a summary line, a second concatenated response, a
   trailing newline plus prompt text — none of which `json.load()` tolerates.
   The error message ("Extra data: line N column M") describes a symptom of
   trailing content, not evidence the JSON itself is malformed. Before
   concluding a file is corrupt or re-running the tool that produced it, try
   `obj, end = json.JSONDecoder().raw_decode(text)` to parse only the first
   complete object and confirm whether the intended payload is intact. This
   does not apply to files legitimately expected to contain JSON Lines
   (one object per line) — that's a different, deliberate format and calls
   for line-by-line parsing instead.

3. A Python-backed CLI (e.g. `az rest`/`az boards` on Windows) can fail
   loudly with a `cp1252` `UnicodeEncodeError`, or worse, silently corrupt
   persisted non-ASCII content, when handling non-ASCII remote text on a
   default Windows console — force UTF-8 via `PYTHONIOENCODING=utf-8` or
   `PYTHONUTF8=1` and verify writes via a file-redirected re-fetch, not
   console output.
   Windows' default console code page (`cp1252` or similar) is what Python
   uses for stdout/stderr encoding unless told otherwise; a CLI that prints or
   round-trips text containing an em dash, curly quote, or non-Latin
   character can raise `UnicodeEncodeError` on the loud path, or on the quiet
   path can transcode the character to `?` or drop it entirely before it
   reaches the remote system, with no error at all. Setting the environment
   variable before invoking the CLI (`PYTHONIOENCODING=utf-8` or
   `PYTHONUTF8=1`) fixes the encoding at the source. Because the silent
   corruption path prints nothing wrong to the console, do not trust console
   output as proof a write succeeded — redirect the tool's own re-fetch of
   the same record to a file and inspect the file's bytes to confirm the
   persisted content matches what was sent.

4. `az boards work-item update` (and similar Python-backed Azure CLI update
   commands) can silently strip HTML entities (e.g. `&rarr;`, `&mdash;`) from
   text fields on update — use plain ASCII punctuation from the first
   attempt instead of HTML entities when scripting ticket updates.
   The stripping happens without a warning or error, so a field that was
   meant to contain `A &rarr; B` can land as `A  B` (or similar), and the
   only way to notice is to re-fetch and diff the field afterward. Rather
   than debugging entity-encoding edge cases per field, default to writing
   plain ASCII punctuation (`->`, `--`, straight quotes) in scripted ticket
   text from the start; it survives the round trip and reads fine in the
   ticket UI.

## Priority

Apply this baseline before ordinary Python scripting habits, but never use it
to override explicit user instructions, safety rules, privacy boundaries, or
stricter repo-local instructions.

## Non-Goals

- This does not cover general Python style (naming, formatting, typing,
  packaging, linting config) — only the four cross-platform, encoding, and
  tool-output correctness traps above.
- This does not require or forbid pytest or any other specific test
  framework; it describes correctness properties the agent's Python output
  and CLI usage should have, however the repo chooses to verify them.
