---
name: verify-concurrent-session-changes
description: Reconstruct a git-diff equivalent by hand to verify whether a parallel session's edits to a shared, non-version-controlled folder conflict with (or resolve) your own work. Use when checking whether another agent or human session's changes to a plain-file shared resource (a personal notes tree, a shared drive, a wiki without full history) broke, contradicted, or corroborated your own recent work — self-initiated or because the user pointed you at a specific already-finished body of work to reconcile against.
status: trial
problem: When two sessions (agent or human) edit the same shared folder concurrently and that folder has no version control, there is no `git diff`/`git log` to lean on to find what changed, whether a rename broke a reference, or whether the change is additive or contradictory — that verification has to be reconstructed manually, and was being re-derived from scratch each time it came up.
when-not-to-use: Do not use this when real version control exists (git, or a wiki with full history) — use `git diff`/`git log` directly for the change-detection and full-read steps; the stale-reference grep (step 2) is still worth doing on top regardless of VCS, but the rest of this procedure is redundant. Do not use for a genuinely single-owner scratch folder with no concurrent-editing risk.
maintainer: Justin Choi
---

# Verify Concurrent Session Changes (Shared, Non-Git Folder)

Built from two dated occurrences of the same gap (2026-08-11 self-initiated
concurrency check; 2026-08-12, different context — user pointed at a
specific already-finished session's output to reconcile against). Clears
`process-vs-work-doctrine` rule 1. Per rule 3, kept in this single-file form
— no spec directory, no install script, no CONTEXT.md — until a third real
use.

## Procedure

### 1. Find candidates by timestamp

List files/folders in the shared tree by modification time, relative to
your own last-known-good state (when you last read or wrote into that
folder). This gives you the candidate set of what changed and roughly when
— not proof of what changed, just where to look.

### 2. Find stale references

If anything in the candidate set was renamed or moved, grep the **entire**
shared tree (not just the changed files) for the old name/path. A hit means
a pointer wasn't updated — something is now broken, not just "different."
Do this step regardless of how thorough step 1's timestamp scan looked;
renames are exactly the kind of change that looks clean by timestamp alone
and broken everywhere else.

### 3. Read full content, not just confirm change

For each genuinely changed or new item, read it completely. A changed
timestamp only tells you *that* something changed, never *how*. Judge
whether the change is additive/consistent with your own work or
contradictory — and say which, explicitly, rather than reporting "nothing
looks broken" as if silence were the finding.

### 4. If the check was pointed-to rather than self-initiated, reconcile bidirectionally

Sharpened by the 2026-08-12 occurrence: when the user explicitly names the
other session's output and asks you to check it, rather than you noticing
the concurrency yourself, don't stop at checking for contradictions to
*your own* claims. Actively look for open items *in the other session's
output* that your own new findings could resolve or update, and surface
those back to the user explicitly. Corrections flow in both directions —
neither source is automatically authoritative over the other just because
one of them is "the other session." The 2026-08-12 occurrence found the
reconciliation cut both ways: the other session's more thorough mapping
corrected a framing this session had already told the user, and this
session's own fresh findings updated an item the other session had left
open.

## Nuance (so this doesn't over-apply)

- Specifically for **non-version-controlled** shared resources. If real
  version control exists, use it directly for steps 1 and 3 — `git
  diff`/`git log` already does both better than manual reconstruction. Step
  2 (stale-reference grep) is still worth running on top regardless of VCS,
  since renames break plain-text pointers either way.
- Not needed for a single-owner scratch folder with no concurrent-editing
  risk.
- Step 4 only applies when the check is pointed-to, not self-initiated —
  don't manufacture "open items to resolve" on a routine self-check where
  nothing was asked about the other session's unresolved work.

## Future work

Could become a scripted pass — given a folder path and a since-timestamp
(or a last-known file listing to diff against), automate steps 1–2
(timestamp listing + stale-reference grep) and hand back a shortlist for
step 3's manual read — rather than reasoning out each step by hand every
occasion. Not building this now; a third recurrence (or a concrete cost
signal from doing steps 1–2 by hand repeatedly) is what would justify it,
per `process-vs-work-doctrine` rule 1.
