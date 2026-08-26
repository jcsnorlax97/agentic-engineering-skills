# Repo Layout

`ai-toolkit` stores reusable AI operating assets without coupling them to one
assistant runtime.

## Canonical Source Trees

```text
skills/
baselines/
bookshelf/
workflows/   # planned
agents/      # planned
templates/   # planned
```

`skills/` owns invoked workflow skills. Skills live under category directories
such as `skills/engineering/` and `skills/media/`. The category describes the
workflow domain, not lifecycle maturity or install scope. Do not move existing
skills merely to express maturity or status.

`baselines/` owns always-on instruction packs. Baselines are applied to
downstream repo instruction files through managed blocks; they are not runtime
skills.

`bookshelf/` owns unprocessed external resource pointers: skill repos, tools,
skill collections, articles, or essays worth remembering before they expire.
One note per resource, indexed in `bookshelf/INDEX.md`. It is a raw capture
surface, not an adoption decision — promoting a bookshelf entry into a skill,
baseline, or spec still goes through `methodology-intake`.

`workflows/` should own reusable tool-neutral workflow specs, role catalogs,
team profiles, execution-packet templates, and handoff contracts once those
definitions are ready to leave `docs/specs/`.

`agents/` should own reusable role or agent profiles only after the profile
contract is proven. Runtime-specific subagent configuration should stay in the
runtime adapter layer.

## Adapter Trees

```text
.claude/skills/
~/.claude/skills/
~/.codex/skills/
```

Adapters expose canonical assets to a runtime. Do not maintain duplicate skill
bodies by hand.

## Script Layout

```text
scripts/
├── baseline
├── baseline.ps1
├── skills.ps1
├── baselines/
├── compat/
├── skills/
└── lib/
```

Root `scripts/` contains public command entrypoints only. Domain folders contain
implementation scripts. `scripts/compat/` contains legacy command names kept for
operators who still know the old paths.

## Lifecycle Metadata

Lifecycle state belongs to SkillOps:

```text
../skillops/inventory/skills.yaml
```

This repo owns the implementation bodies, not central lifecycle inventory.
