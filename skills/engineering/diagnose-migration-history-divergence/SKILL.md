---
name: diagnose-migration-history-divergence
status: trial
problem: An EF Core deploy or rollback against a shared environment fails, or risks failing, with a confusing "migration '<id>' was not found" state because the target's __EFMigrationsHistory table contains migrations absent from the deploying/rolling-back branch's Migrations folder — usually because someone applied an unmerged branch's migrations directly to that shared environment. Root-causing which branch/author introduced the divergent migrations, and whether they're safe to work around, otherwise takes several manual git-forensics steps redone ad hoc under incident pressure each time it happens.
when-not-to-use: The migration framework has no greppable applied-migrations table with one-class-per-migration files in git (this depends on EF Core's __EFMigrationsHistory convention); the target is a personal/local dev DB where mismatches are expected and low-stakes, not a shared environment; or you already know which unmerged branch caused the divergence and just need to execute the fix — this skill stops at diagnosis and risk classification, never at running the rollback/fix itself.
maintainer: Justin Choi
description: Diagnose EF Core migration-history divergence between a target environment's __EFMigrationsHistory table and a deploying or rolling-back branch's Migrations folder — trace each divergent migration to its origin branch/author/merge-status via git, classify its risk, and produce a hand-off report. Triggers on "migration history divergence", "migration was not found" deploy failures, "EF Core migration mismatch between environments", and "pending model changes" / rollback-planning questions before running Update-Database against a shared environment.
---

# Diagnose Migration-History Divergence

Use when an EF Core deploy or rollback against a **shared** environment
(not a personal dev DB) surfaces a `migration '<id>' was not found` error,
or before running `Update-Database` / `dotnet ef database update` against a
shared environment as a rollback. Either situation means the target's
`__EFMigrationsHistory` may contain migrations the current branch doesn't
know about.

## Why this is skill-shaped, not a one-off fix

Any team running EF Core migrations against a shared environment from
multiple parallel branches can hit "the environment has migrations the
current branch doesn't know about" — typically because someone applied an
unmerged branch's migrations directly to that environment, whether as a
deliberate shortcut or by accident. The failure mode shows up from two
different entry points that look unrelated at first:

- A **deploy pipeline** fails applying a new migration with a "migration
  ... was not found" error that's confusing on its face, since the named
  migration usually isn't the one actually being deployed.
- A **planned rollback** (`Update-Database <id>` or equivalent) silently
  targets the wrong point in history, or fails outright, because the
  branch doing the rollback also doesn't contain the divergent migrations
  sitting in the environment's history table.

Same root cause, same multi-step manual git trace, done by hand each time
regardless of which entry point surfaced it. The diagnostic sequence
generalizes even though the specific divergent migrations, branches, and
authors differ every time it recurs.

## Inputs

Ask for, or infer from the conversation, before starting:

1. The target environment (e.g. a shared integration or staging
   environment) and either a connection to query it directly, or a pasted
   `__EFMigrationsHistory` dump / the error message naming the missing
   migration.
2. The local repo path and which branch is being deployed, or is about to
   run a migration command against that environment.
3. The `Migrations/` project path(s) — EF Core setups sometimes split
   `DbContext` and migrations across projects, so get both `--project` and
   `--startup-project` if `dotnet ef` commands will be needed.

## Procedure

### 1. Get the environment's actual applied-migration set

Query the target directly if you have a connection:

```sql
SELECT MigrationId, ProductVersion
FROM __EFMigrationsHistory
ORDER BY MigrationId;
```

Otherwise parse the migration ID out of the "was not found" error, or use
whatever `__EFMigrationsHistory` dump was pasted into the conversation.

### 2. Get what the deploying/current branch knows about

```powershell
dotnet ef migrations list --project <MigrationsProject> --startup-project <StartupProject>
```

This lists every migration the branch's assembly contains (marking any not
yet applied to whatever DB it's currently pointed at). If `dotnet ef` isn't
runnable in context (e.g. wrong connection string reachable from here),
cross-reference by filename against `Migrations/*.cs` instead — each
migration's ID is the `yyyyMMddHHmmss_Name` prefix of its filename.

### 3. Diff to find the divergent set

Divergent migrations = present in the environment's `__EFMigrationsHistory`
but **absent** from the branch's `Migrations/` folder. This is the set that
doesn't belong to any history the current branch has ever merged — and any
migration command (a deploy, or an ordinary `Update-Database <target>` used
for a rollback) that targets a point in the history *before* these
divergent entries can misfire, since EF walks `__EFMigrationsHistory`
sequentially and doesn't know how to skip entries it has no matching class
for.

### 4. Trace each divergent migration to its origin

For each divergent `MigrationId`, find the commit that introduced its file:

```bash
git log --all --diff-filter=A -- '**/Migrations/*<MigrationId>*.cs'
```

Confirm whether that commit ever reached the deploy target branch (usually
`main`):

```bash
git merge-base --is-ancestor <commit> main && echo "merged" || echo "NOT merged"
```

If not merged, identify the actual owning branch(es) and author:

```bash
git branch --all --contains <commit>
git log -1 --format='%an %ae' <commit>
```

### 5. Classify risk per divergent migration

Open each divergent migration's `Up`/`Down` bodies and classify:

- **Lower risk** — stored procedure, view, or function bodies only (e.g.
  `migrationBuilder.Sql("CREATE OR ALTER PROCEDURE ...")`); no
  `CreateTable`, `AddColumn`, `DropColumn`, `AlterColumn`, or data-mutating
  `Sql(...)` calls.
- **Higher risk** — schema changes (`AddColumn`, `DropColumn`,
  `CreateTable`, `AlterColumn`) or data-mutating SQL. These can make a
  rollback destructive, or leave the environment's schema in a state the
  current branch's model doesn't expect.

### 6. Produce the hand-off report

State, per divergent migration: ID, origin branch, author, merge status
(merged / not merged, and where), and risk classification. Then state
plainly what the safe next step is for a human to choose from — for
example: "coordinate with `<author>` before touching this environment,"
"these N migrations are stored-proc-only and likely safe to leave in
place," or "do not run `Update-Database <id>` past this point without
confirming with `<author>` first."

**Do not execute a rollback, a migration-history edit, or an
`Update-Database` command yourself.** That decision, and its execution,
belongs to a human — especially against a shared or production-adjacent
environment.

## Non-Goals

- This does not fix or roll back the divergence itself — diagnosis and
  risk classification only.
- This does not generalize to migration frameworks without an accessible,
  greppable applied-migrations table and one-class-per-migration git
  history (this depends on EF Core's `__EFMigrationsHistory` convention).
- This does not replace coordinating with the divergent migration's author
  before mutating a shared environment.
