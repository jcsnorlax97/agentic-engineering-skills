# Handoff Document Discipline Baseline

Status: active
Version: 0.1.0

Always-on lifecycle discipline for a **living snapshot document** — a plan,
implementation status doc, or "paste this to resume" prompt that gets
overwritten in place as work progresses, rather than a dated append-only
record. This repo's own `docs/handoffs/YYYY-MM-DD-<slug>.md` convention (see
`docs/how-to/handoffs.md`) already avoids the in-place-overwrite failure mode
by being dated and append-only — this baseline is for the *other* shape of
handoff doc: any file a project keeps as a single living resume/plan doc that
gets edited in place across a session or across sessions.

## Principles

1. Archive the prior version before overwriting a living handoff doc in
   place.
   Before replacing the entire content of a document that's reused as "the
   thing to read to pick this back up" (a resume prompt, an implementation
   plan, a status snapshot), save the pre-overwrite version as a separate
   file first — unless the document is already under real version control
   where the prior version is trivially recoverable from history. A wholesale
   in-place rewrite with no version control is not recoverable once done.

2. Re-read a long handoff doc linearly for self-contradiction before
   dispatching it.
   A handoff/plan doc that's accumulated additive "correction" sections over
   a long session is prone to earlier sections going un-reconciled with later
   ones. Before handing it to a fresh session or another person, read it
   start-to-finish as a single linear document — not just the latest diff —
   specifically checking whether an earlier section still says something a
   later correction contradicts.

## Priority

Apply this baseline before overwriting or dispatching a living
plan/resume/status document, but never use it to override explicit user
instructions, safety rules, privacy boundaries, or stricter repo-local
instructions — including this repo's own dated-handoff convention where it
applies instead.

## Non-Goals

- This does not apply to dated, append-only handoff files (this repo's
  `docs/handoffs/` convention already avoids the overwrite failure mode by
  design).
- This does not define what a handoff document should contain, only its
  lifecycle safety around edits and dispatch.
