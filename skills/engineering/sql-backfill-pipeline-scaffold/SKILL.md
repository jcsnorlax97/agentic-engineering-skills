---
name: sql-backfill-pipeline-scaffold
status: trial
problem: A data-fix/backfill that recovers a value by walking a chain across multiple database systems (a local DB, a join key into another system's log table, extracting the original value from a logged response) reinvents the same shape piece by piece over a session — phase numbering, an ID-batching helper, a verify/mutate split — each discovered only after the simpler version hit its limit.
when-not-to-use: A single-table, single-DB fix with no multi-system hop, a small enough ID list to hand-type safely, and a mutation you're running yourself rather than handing off. That doesn't need phase folders, a Python helper, or a formal verify/mutate split — just fix it directly.
maintainer: Justin Choi
description: Scaffold a multi-phase SQL Server backfill/data-recovery pipeline that walks a chain across multiple systems to recover a corrupted value — numbered phase scripts, a batched ID-input helper, a hard read-only-verify vs. mutate split that branches on row count, and a command-steps runbook.
---

# SQL Backfill Pipeline Scaffold

Use when recovering a corrupted value requires walking a chain across two or
more systems (e.g. a local DB → a join key into another system's log table →
the original value extracted from a logged JSON response), and the mutation
will eventually be handed to someone else (a DBA, another team) to run against
production.

## Inputs

Ask for, or infer from the conversation, before scaffolding:

1. What was corrupted, and the chain of systems/DBs needed to recover the
   correct value (name each system and the join key between consecutive
   hops).
2. Roughly how many rows are affected. This determines which mutate shape to
   generate — see "Verify/mutate split" below. If unknown, ask; do not
   default to the small-batch shape silently.
3. Who runs the final mutation — you, in this session, or a hand-off to
   someone else. A hand-off raises the bar on self-guarding.

## Scaffold shape

```
docs/
  plan.md                  # what's corrupted, the recovery chain, current status
  resume-prompt.md         # "paste into a fresh session" prompt with a living status section
phases/
  phase1-<name>.sql        # RUN AGAINST: <DB> banner comment at the top of every phase file
  phase2-<name>.sql
  ...
scripts/
  batch-ids.py             # --table/--column flags; one generalized helper, not one per phase
command-steps.md           # file -> DB target -> input -> output, plus exact shell commands
```

- Every `phaseN` SQL file starts with a `-- RUN AGAINST: <DB>` banner comment
  so the person executing it can't misapply it to the wrong database.
- `batch-ids.py` reads a plain list of IDs from a file, de-duplicates,
  validates the ID shape, and emits a batched `INSERT ... VALUES` block sized
  under SQL Server's ~1000-row `VALUES` limit — parameterized by `--table` and
  `--column` so it's reused across phases, not rewritten per phase.
- `command-steps.md` is the single runbook: one row per step, naming the file,
  the DB it targets, its input, its output, and the exact runnable command.

## Verify/mutate split — branch on row count

Do not assume one shape always applies. Ask "how many rows, roughly?" and
pick:

**Small batch (well under SQL Server's ~5,000 row/page lock-escalation
threshold):**
- One script that is read-only by construction: build, validate, and preview
  the target set — no `UPDATE`, `DELETE`, or open transaction anywhere in it.
- A separate, minimal hand-off script containing the *only* mutating
  statement: a single guarded transaction (`UPDATE ... JOIN`) that compares
  actual vs. expected row count and rolls back automatically on mismatch.

**Large batch (approaching or exceeding the lock-escalation threshold):**
- A single guarded transaction is not safe here — one statement holding locks
  on thousands of rows risks escalating to a table lock for the run's
  duration, and an unindexed table-variable join becomes an unpredictable
  query-plan bet at that row count.
- Generate one `UPDATE ... WHERE <primary key> = X AND <same guard predicate>`
  statement per row instead, each auto-committed (no single transaction spans
  more than one row's locks). Every statement carries its own idempotency
  guard, so re-running the whole file after a partial or interrupted run is a
  safe no-op on rows already fixed.
- Follow with a trailing count-based verification query (count of target rows
  still unfixed — expect 0) rather than an in-transaction row-count check.
- Keep any earlier small-batch script as a documented "legacy — small-batch
  fallback only" reference rather than deleting it, so the reason it doesn't
  scale stays attached to the code.

Apply [`sql-server-safety`](../../../baselines/sql-server-safety/baseline.md)
to every script this skill generates — in particular: the read-only verify
script must contain zero mutating statements, the verify and mutate scripts
must share one written predicate rather than two independently maintained
copies, and no verification/completion query may carry `NOLOCK`.

## Non-Goals

- This does not replace DBA review for genuinely high-risk production
  mutations.
- This does not generate the recovery-chain logic itself (the join keys and
  extraction logic are specific to the systems involved) — it scaffolds the
  file structure, batching helper, and verify/mutate split around that logic.
