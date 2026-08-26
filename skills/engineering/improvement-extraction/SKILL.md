---
name: improvement-extraction
description: Scan the current session for candidate CLAUDE.md/AGENTS.md baselines, candidate Claude Code skills, or improvements to an existing baseline/skill/template, and write them as structured notes to a configurable output folder for later manual review. Use when the user asks to extract improvement ideas, capture process improvements, or save candidate baselines/skills surfaced during this session — phrases like "extract improvements", "capture what we'd add to CLAUDE.md", or "save this as a candidate skill idea".
status: trial
problem: Candidate process improvements (baseline rules, skill ideas) surfaced during a session were only captured by manually asking, in full sentences, for the session to be scanned and written up — a repeated, mechanizable step done by hand every time.
when-not-to-use: Do not use for capturing a full session log (that belongs to a work-log capture skill such as capture-assistant-session), for cross-company-portable personal lessons (that belongs to a personal-vault lesson-extraction skill), or for ideas too narrow to generalize past the current task.
maintainer: Justin Choi
---

# Improvement Extraction

Scan the current session for candidate CLAUDE.md/AGENTS.md baselines or candidate skills, and write each as a structured note to a configurable output folder. This is a scratch capture step — candidates land here for later manual review, not automatic promotion into this repo's baselines or skills.

## Step 1 — Resolve the output root

- Read `IMPROVEMENTS_ROOT` from the environment.
- If unset, ask the user for the path once, then use it for this run only. Tell them how to persist it so this step isn't needed again:
  - Windows: `setx IMPROVEMENTS_ROOT "<path>"`
  - macOS/Linux: `export IMPROVEMENTS_ROOT="<path>"` in their shell profile
- Never write the resolved path into this skill file or any committed content — the environment variable is the only place it lives.

## Step 2 — What counts as a candidate

Three categories qualify:

1. **Candidate portable baseline** — a rule that, had it existed in CLAUDE.md/AGENTS.md at the start of the session, would have prevented a mistake, correction, or ambiguity that actually came up. General enough to survive a future session or a different repo.
2. **Candidate skill** — a repeatable, at least partly mechanizable procedure that came up this session and would be cheaper to run as a scripted/semi-scripted skill next time than to redo by hand.
3. **Candidate improvement to an existing skill/baseline/template** — a friction point hit while actually *using* one this session: a verbose template, an ambiguous step, two sections that always say the same thing, a rule that no longer fits how it gets applied. Don't limit the scan to brand-new ideas; using an existing tool is itself a chance to spot what it should stop doing.

Exclude: routine bug fixes, one-off decisions, anything already covered by an existing baseline or skill, and anything too narrow to generalize past this one task.

## Step 3 — Dedup against existing notes

List the files already in `IMPROVEMENTS_ROOT` and skim their titles and first paragraphs. If a new candidate is a variation or reinforcement of an existing note's topic, extend that file (add an observation, a nuance, a "seen again" note) instead of creating a near-duplicate.

## Step 4 — Write one file per genuinely new idea

Filename: `kebab-case-topic.md`. Use this structure — every field earns its words; skip a section if the one above it already covers it:

```markdown
# <the rule/skill, one line>

**Captured:** <date> — <repo/PR, one line>

## Trigger
<the incident that surfaced this — self-contained, no restating in a second section>

## Rule
<the actionable rule or skill, stated directly>

## Boundary
<where this should NOT apply — omit if there's no real risk of over-applying it>

## Next step
<what it'd take to formalize this — omit if "review and adopt" is all there is to say>
```

Write tight: one word beats two if it carries the same meaning, two words beat a clause, a clause beats a sentence. Don't restate the same fact in two sections (the old "observation" vs. "what triggered this" split routinely did — that's why they're merged into one `Trigger` section now).

No confirmation gate before writing — `IMPROVEMENTS_ROOT` is a working/scratch folder for candidate ideas, not curated long-term memory or this repo's governed skill/baseline inventory.

## Step 5 — Report back

State which files were created vs. extended, with a one-line summary of each.

## Relationship to other end-of-session tools

This is a third, distinct capture tool, not a replacement for whatever session-log or personal-lesson skills already exist in this environment:

- A **session-log capture skill** (e.g. `capture-assistant-session`) → full session log, written to a personal work-log vault.
- A **lesson-extraction skill** → sanitized, cross-company-portable personal knowledge distilled into a personal vault for the user's own long-term reference. It is not aimed at producing a repo baseline or skill.
- `improvement-extraction` (this skill) → things learned this session that could become a future CLAUDE.md/AGENTS.md baseline rule or a Claude Code skill, written as one candidate markdown file per idea so each can be reviewed and formalized into an actual baseline or skill later, one at a time. Stays inside the work context (a project folder), not a personal vault.

If neither of the other two skills exists in this environment, that's fine — this skill still runs standalone.
