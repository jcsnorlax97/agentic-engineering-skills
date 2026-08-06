---
name: session-closeout
description: Chain the personal end-of-session skills — a session-log capture skill, lesson-extraction, and improvement-extraction — into a single wrap-up pass instead of invoking them one at a time. Use when the user wants to close out, wrap up, or end a work/coding session and capture everything worth keeping in one go. Triggers on "wrap up this session", "close out", "let's wrap", "session closeout", "收工", "收官三連".
status: trial
problem: Ending a work session that produced a session log, a personal lesson, and a repo-specific improvement candidate required three separate skill invocations every time, each easy to forget individually.
when-not-to-use: Do not use inside the personal knowledge vault itself — that repo runs its own after-action.md three-step process (after-action, capture-assistant-session, lesson-extraction; no improvement-extraction, since the vault isn't a company/work repo). Do not use for a session that produced nothing worth keeping; each sub-skill already knows how to report "nothing to capture."
maintainer: Justin Choi
---

# Session Closeout

Chain three personal skills into one end-of-session pass instead of invoking each separately: a session-log capture skill (e.g. `capture-assistant-session`), `lesson-extraction`, and `improvement-extraction`. This skill does not duplicate their logic — it only sequences them and reports one consolidated summary. If any of the three changes its own behavior later, this skill picks that up automatically since it just invokes them by name.

## When to run this

At the natural end of a work/coding session in a company or project repo — not the personal knowledge vault (see `when-not-to-use`; that repo already has its own three-step after-action process).

## Step 0 — Check availability

This skill lives only in `ai-toolkit`; the three skills it sequences do not. None of them ship with this repo, and any of the three may be missing on a given machine or for a given user. Before running each step, check whether that step's skill is present in the current skill listing. A missing skill is a normal, expected outcome here, not an error — note it plainly in the final report and move on to the next step.

## Step 0.5 — Check for a prior compaction, and mine the raw transcript if so

Steps 1-3 only ever see what's in the live conversation context. If this session was auto-compacted at any point, that context is a summary plus everything after it — not the original transcript — and a summary's job is preserving task continuity, not preserving every extractable lesson. Before running Step 1, check whether this session was compacted:

- **Detect**: look for a compaction marker already present in context — a message stating the conversation is "being continued from a previous conversation that ran out of context" (or equivalent), or a visible summary block standing in for earlier turns. If there's no such marker, this step is a no-op — skip straight to Step 1. Don't go looking for a transcript file on a session that was never compacted.
- **Locate**: if a compaction marker is present, find the session's raw JSONL transcript on disk (Claude Code persists the full raw transcript regardless of in-context compaction) — typically under a `~/.claude/projects/<project-slug>/` directory, named by session ID. The session ID and project slug are derivable from the current session's own metadata/working directory.
- **Mine, bounded**: delegate a single subagent to do a *targeted* pass over the pre-compaction portion of that transcript — not a full re-read. Bound the cost explicitly:
  - Grep for a fixed pattern set before reading: correction/pushback language ("actually", "wait", "no,", "instead", "don't", "I don't want"), decision language ("decided", "chose", "instead of doing X we"), error/failure strings ("Exception", "error:", "failed", "violat"), and confirmation language ("yes exactly", "that's right", "perfect").
  - Read context only around hits, not the whole file linearly.
  - Give the subagent an explicit stop condition (e.g. "stop once you've covered the full pre-compaction portion or spent roughly N tool calls, whichever first") so a very large session can't turn this into an unbounded pass.
  - Ask it to report back candidate lessons/improvements in the same shape Step 2/3 expect (situation → rule, plus enough concrete detail to judge sanitization), explicitly flagging anything already covered by the in-context summary so it isn't re-proposed.
- **Fold in**: treat what this pass finds as additional candidates for Step 2 (lesson-extraction) and Step 3 (improvement-extraction) — same confirm-before-write gate applies to anything it surfaces that's lesson-shaped; no gate for anything improvement-shaped.

This step exists because it happened twice without it: a session ended, `session-closeout` ran normally, the user asked afterward whether compaction might have dropped something, and a manual mining pass confirmed it had — both times. Making this automatic means the user shouldn't need to ask.

## Step 1 — Session-log capture

If a session-log capture skill (e.g. `capture-assistant-session`) is available, invoke it via the Skill tool. If none is installed on this machine, note that plainly and move on to Step 2 — do not treat it as a hard failure, and do not attempt to reproduce its behavior manually as a substitute.

## Step 2 — Lesson extraction

If `lesson-extraction` is available, invoke it via the Skill tool. It has its own confirm-before-write gate into the personal vault. Do not skip or auto-approve that gate on the user's behalf — let it run exactly as it's designed to, including asking the user to confirm before writing. If it isn't installed, note that plainly and move on to Step 3.

## Step 3 — Improvement extraction

If `improvement-extraction` is available, invoke it via the Skill tool. It writes candidate baseline/skill notes to `IMPROVEMENTS_ROOT` with no confirmation gate, since that folder is scratch material for later manual review. If it isn't installed, note that plainly and move on to Step 4.

## Step 4 — Consolidated report

After all three steps finish, are explicitly skipped, or turn out unavailable, give the user one summary covering all three: what was written, what was extended, what each skill found nothing worth capturing, and which steps were skipped because a skill wasn't installed. If Step 0.5 ran and found anything, say so explicitly (what it found, and that it came from mining the pre-compaction transcript, not the live context) rather than folding it in silently. Do not print three separate skill reports back to back — merge them into a single readable summary.

## Notes

- Run the steps in order, not in parallel. `lesson-extraction`'s confirmation gate is interactive and should resolve before moving on to the next skill.
- A missing skill on this machine is expected, not a bug in this skill — say so plainly in the report rather than silently skipping it without mention, and never fake or hand-roll that skill's output as a stand-in.
- This is a sequencer, not a rewrite of any of the three skills' logic. Improvements to the individual skills' triggers, gates, or output formats apply automatically the next time this runs.
