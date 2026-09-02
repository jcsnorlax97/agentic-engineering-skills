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
- **Fold in**: treat what this pass finds as additional candidates for Step 2 (lesson-extraction) — same confirm-before-write gate applies to anything it surfaces that's lesson-shaped. Do not fold these into Step 3's candidates — Step 3 handles the compacted case itself (see Step 3) using `improvement-extraction`'s own full-sweep mode, which gives exhaustive per-chunk coverage rather than this pass's keyword-matched approximation. `lesson-extraction` has no equivalent full-sweep mode, so this bounded pass remains the only compaction recovery it gets.

This step exists because it happened twice without it: a session ended, `session-closeout` ran normally, the user asked afterward whether compaction might have dropped something, and a manual mining pass confirmed it had — both times. Making this automatic means the user shouldn't need to ask.

*(2026-09-02 refinement: originally this step's findings fed both Step 2 and Step 3. Since `improvement-extraction` has its own native full-sweep mode, delegating Step 3's compacted case to it directly gives strictly better coverage than this step's grep-pattern approximation, for that skill specifically — see Step 3.)*

## Step 1 — Session-log capture

If a session-log capture skill (e.g. `capture-assistant-session`) is available, invoke it via the Skill tool. If none is installed on this machine, note that plainly and move on to Step 2 — do not treat it as a hard failure, and do not attempt to reproduce its behavior manually as a substitute.

## Step 2 — Lesson extraction

If `lesson-extraction` is available, invoke it via the Skill tool. It has its own confirm-before-write gate into the personal vault. Do not skip or auto-approve that gate on the user's behalf — let it run exactly as it's designed to, including asking the user to confirm before writing. If it isn't installed, note that plainly and move on to Step 3.

## Step 3 — Improvement extraction

If `improvement-extraction` is available, invoke it via the Skill tool. **If Step 0.5 detected compaction, invoke it in full-sweep mode** (pass `full-session`/`--fs`) instead of its default scope — its own exhaustive per-chunk-agent scan gives full coverage of the pre-compaction transcript, rather than relying on Step 0.5's cheaper keyword-matched approximation for this step's candidates. Accept the real per-chunk token cost (~100-120k tokens/chunk) in that case: this is the same failure mode Step 0.5 exists for (compaction silently dropping a candidate), which has already occurred twice, and `improvement-extraction`'s own full-sweep is strictly more thorough than Step 0.5's grep-based pass for this skill specifically. If no compaction was detected, invoke it in its normal default-scope mode as before. It writes candidate baseline/skill notes to `IMPROVEMENTS_ROOT` with no confirmation gate, since that folder is scratch material for later manual review. If it isn't installed, note that plainly and move on to Step 4.

## Step 3.5 — Improvements backlog nudge

Added after the third dated occurrence (2026-07-29, 2026-08-07, 2026-08-25) of
the identical failure: `_Improvements/` piles up between `baseline-gap-review`
passes because nothing ever prompts a review — Step 3 writes into the folder
every session, nothing reads it back out on its own. Three occurrences with
the same diagnosis is not a coincidence to keep re-diagnosing; it's a
structural gap this step closes with the smallest possible check.

Only run this if Step 3 ran (skip if `improvement-extraction` wasn't
available). Resolve `IMPROVEMENTS_ROOT` the same way Step 3 does. Then:

1. Count the `.md` files directly under `IMPROVEMENTS_ROOT` (not its `Done/`
   subfolder).
2. Find the most recent `Done/<date>-baseline-consolidation-manifest.md` and
   read its date from the filename.
3. If the count exceeds **40 files**, or the most recent manifest is more
   than **14 days** old, add one line to the Step 4 report: that the
   `_Improvements/` backlog looks due for a `baseline-gap-review` pass, with
   the current count and days-since-last-manifest, and that the user can run
   `/baseline-gap-review` whenever convenient. Do not invoke the review
   yourself — this is a nudge, not an automatic trigger; the user still
   decides when to run it.
4. If neither threshold is crossed, say nothing about it — this is a
   suppress-by-default nudge, not a status line that prints every time.

These thresholds are derived from the three real occurrences to date (41
files/9 days between #1→#2, 95 files/18 days between #2→#3) — revisit them if
a fourth occurrence shows the backlog growing at a different rate than this
extrapolation assumed.

## Step 4 — Consolidated report

After all three steps finish, are explicitly skipped, or turn out unavailable, give the user one summary covering all three: what was written, what was extended, what each skill found nothing worth capturing, and which steps were skipped because a skill wasn't installed. If Step 0.5 ran and found anything, say so explicitly (what it found, and that it came from mining the pre-compaction transcript, not the live context) rather than folding it in silently. If Step 3 ran in escalated full-sweep mode (compaction detected), say so explicitly rather than reporting it the same as a normal-scope run. If Step 3.5 flagged the backlog, include its one line. Do not print three separate skill reports back to back — merge them into a single readable summary.

## Notes

- Run the steps in order, not in parallel. `lesson-extraction`'s confirmation gate is interactive and should resolve before moving on to the next skill.
- A missing skill on this machine is expected, not a bug in this skill — say so plainly in the report rather than silently skipping it without mention, and never fake or hand-roll that skill's output as a stand-in.
- This is a sequencer, not a rewrite of any of the three skills' logic. Improvements to the individual skills' triggers, gates, or output formats apply automatically the next time this runs.
