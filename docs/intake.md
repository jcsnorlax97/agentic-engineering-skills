# Intake

This file tracks unprocessed notes, article captures, and rough research briefs
that may inform future skills, specs, ADRs, or glossary updates.

Intake items are not design decisions. Treat them as inputs to future grilling
sessions until they have been verified, challenged, and either accepted into
canonical docs or rejected.

Classification of external methodology sources is owned by the
`methodology-intake` skill; this file is its ledger for `parked` and
`revisit-on-trigger` verdicts.

For raw, not-yet-evaluated external resources (skill repos, tools, articles)
worth remembering before they expire, see [`bookshelf/INDEX.md`](../bookshelf/INDEX.md).
A bookshelf entry becomes an intake verdict only once it goes through
`methodology-intake`.

## Intake Verdicts

- 2026-07-05 — X post @mylifcc (Fable5 workflow) + `majiayu000/spellbook`:
  destination `Rule` (weak-model instruction audit, absorbed into
  `docs/high-stakes-session-brief-template.md`, commit `fd8dc87`); retention
  `revisit-on-trigger` — re-evaluate spellbook's `codebase-audit` skill only
  after two dated failures show a missing audit capability, and prefer lifting
  the `staff-level-review` probation over importing a new skill.

## Scratch Captures

Scratch captures may live under:

```text
.scratch/captures/
```

Capture processing status:

- `.scratch/captures/2026-05-21-founder-playbook-skills-grill-brief.md`
  remains unprocessed.
- `.scratch/captures/2026-05-21-methodology-intake-skills-grill-brief.md`
  produced the initial `methodology-intake` skill and glossary updates. Keep it
  available as source evidence for future intake examples and follow-up skills.

Current external review-workflow references to grill before adoption:

The local `staff-level-review` skill now exists and is derived from
`docs/specs/0004-staff-level-review.md`. The references below remain parked;
do not import them unless source, license, and fit are verified.

- User-provided legacy `staff-review` skill: useful as a reference for review
  dimensions, severity labels, and constructive review principles. Do not import
  directly; grill against `docs/specs/0004-staff-level-review.md` first.
- ClaudSkills `staff-review`: conceptually relevant, but license/source details
  must be verified before importing.
- `speckit-staff-review-run`: relevant as a read-only staff-level review
  pattern, but appears tied to spec-kit structure.
- Empire `team-review`: relevant as a specialist review/team review pattern;
  license and source should be checked before reuse.
- Nanostack workflow model: relevant for phase-based delivery and artifact
  handoff, but not a direct staff-review skill.

## Processing Rules

- Do not commit `.scratch/captures/`.
- Do not promote capture content into a skill or spec without grilling it.
- Check source license and attribution before importing any external material.
- Convert accepted ideas into `CONTEXT.md`, a spec, an ADR, or a skill.
- Leave rejected or unverified ideas out of canonical docs.
