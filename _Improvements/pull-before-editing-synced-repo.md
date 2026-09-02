# Fetch and compare against origin before editing a repo known to sync across machines

**Captured:** 2026-09-02 — vault-for-founders / ai-toolkit session

## Trigger
Edited `README.md` and `sop/vault-changelog.md` in `vault-for-founders`
against a local HEAD that was 6 commits behind origin (another machine had
pushed the same day). Discovered only because the user asked "did you pull
first?" — not caught proactively. `git status` looked clean locally the
whole time; clean working tree says nothing about how far behind origin
HEAD is. Same thing then found true of `ai-toolkit` moments later when
checked proactively (2 commits behind), this time caught before editing.

## Rule
In any repo known to be worked on from more than one machine (personal
vault, shared toolkit repo), run `git fetch && git rev-list --left-right
--count HEAD...origin/main` before making edits, not just before
committing. A clean local `git status` only proves no uncommitted local
changes — it says nothing about whether HEAD itself is stale.

## Boundary
Not needed for genuinely single-machine, single-session repos (e.g. a
throwaway scratch project) where "behind origin" can't happen.

## Next step
Check whether `git-collaboration-hygiene` already covers this — if so,
extend it with the "clean status ≠ up to date" distinction and the
`rev-list --left-right --count` check specifically, rather than adding a
new baseline.
