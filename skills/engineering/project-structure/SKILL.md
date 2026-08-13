---
name: project-structure
description: Scaffold a new personal project folder under a-projects/ with a standardized skeleton (master index, business/domain glossary, external-documentation folder, a stable home for design-decision sessions), or audit an existing organically-evolved project folder against that same convention and propose a migration plan for approval. Use this whenever the user wants to start a new project folder for ongoing multi-session work (a new client, initiative, or investigation), says things like "set up a project structure," "scaffold a project," "apply the project structure to X," or is about to create a new top-level folder/file in an existing a-projects/ folder without first checking whether an established convention already covers it. Also trigger proactively when a project folder has clearly grown ad hoc — multiple sessions each inventing new top-level folders with inconsistent naming (numbered vs. not, PascalCase vs. spaces vs. underscores) — even if the user hasn't explicitly asked to fix it.
---

# Project Structure

Scaffold a new personal project folder under `a-projects/` with a standardized skeleton, or audit an existing one against the same convention and propose a migration — never applied automatically.

## Why this convention exists

This isn't an arbitrary standard invented up front. It's extracted from a real, long-running project folder that organically evolved a structure across many work sessions — a master index, a business/domain glossary, a specs folder, numbered story folders — and that structure proved itself: sessions found things faster because of it, and its author explicitly said they liked the index + glossary pattern once it existed. The rule going forward: **check this convention before inventing new top-level structure in any project folder**, the same "mirror a sibling convention before inventing your own" habit that already applies to code and docs — just now with an actual template to mirror, instead of every project rediscovering its own structure from scratch.

Read this whole file before scaffolding or auditing anything — the convention only helps if it's applied consistently, and a half-remembered version of it is worse than checking the real thing each time.

## The convention

**Fixed reference folders** — exactly one of each, not chronologically ordered relative to one another, so no number prefix: PascalCase, no spaces (spaces in folder names cause real friction — every shell command touching them needs quoting, which this exact convention has already been bitten by once).

- **Always create when scaffolding a new project:**
  - `Glossary/` — business/domain term reference, one file per term, kept separate from any code-repo `CONTEXT.md` (that's precise code-domain vocabulary; this is "what does this business/telecom/industry term mean and why does the project care," for readers without that background). **A concept earns its own file once it's a distinct named entity/mechanism (not just a flag/field on another term) referenced from two or more other glossary entries** — this bar exists because it's easy to explain a related concept inline while writing a different term's file and never circle back to give it its own entry (this happened once already: a central connecting table got referenced from two files while writing them, met the bar, and had no file of its own until a direct re-check caught it). If a term meets the bar but doesn't get written yet, disclose that explicitly in `Glossary/README.md` rather than leaving the gap silent.
  - `ExternalDocumentation/` — specs, vendor docs, legacy internal docs, anything authored by someone else that the project treats as reference material rather than its own decisions.
  - `Grilling/` — design-decision / grilling-session output. One dated subfolder per session (`Grilling/YYYY-MM-DD-topic/`), not a new top-level `YYYYMMDD-Grilling/` folder invented each time — that ad hoc pattern is exactly what this skill exists to replace.
- **Create on demand, only when actually needed** — don't pre-create empty folders nobody's using yet: `MeetingPrep/`, `ToImplementNotes/`, `DbNotes/`, `Bugs/`, `SetupNotes/`, or whatever cross-cutting category a specific project turns out to need. List these as available names in the scaffolded `0000-INDEX.md` so a future session reaches for one of them instead of inventing a new name for the same kind of thing.

**Sequential story/ticket folders** — one per unit of work, numbered because creation order genuinely matters here: `00N-<ticket-id>-<short-kebab-name>/` (e.g. `007-4521-migrate-billing-export/`). This part already worked before this skill existed — don't change it, just keep using it.

**One deliberate exception**: `0000-INDEX.md` keeps its numeric prefix specifically so it sorts before every PascalCase folder and every `00N-...` story folder in a plain alphabetical directory listing. State this explicitly inside the INDEX itself (the template below already does) so it reads as an intentional choice, not leftover inconsistency.

**Files within any folder**: kebab-case `.md` — matches what already works inside `Glossary/` and in story-folder files like `implementation-plan.md`.

## Scaffolding a new project

1. Confirm the project name and location with the user if it's not obvious from context — default to a new folder directly under `a-projects/`, matching sibling project folders. List `a-projects/` first (`Glob`/`ls`) rather than assuming what's already there or what naming pattern siblings use.
2. Create:
   - `0000-INDEX.md` — copy `references/index-template.md`, filling in the project name and leaving the quick-answers table and folder map with their example/placeholder rows until real content exists to point at. Don't invent example content — an empty table with a header is more honest than filled-in placeholders that look like real entries.
   - `Glossary/README.md` — copy `references/glossary-readme-template.md` verbatim (it's already generic).
   - `ExternalDocumentation/README.md` — copy `references/external-documentation-readme-template.md` verbatim.
   - `Grilling/` — create the empty folder itself; don't create a dated subfolder yet, that happens when an actual session needs one.
3. Report the created structure back to the user, and mention explicitly: story folders (`00N-<ticket-id>-<short-name>/`) get created as real work starts, not upfront — an empty `001-.../` folder before any ticket exists is just clutter.

## Auditing or retrofitting an existing project

Existing projects evolved before this convention existed and won't match it exactly, and that's expected — this is a retrofit tool, not a "you did it wrong" tool.

**Never rename or restructure anything automatically.** Renaming a folder in one of these projects touches every cross-reference in its `0000-INDEX.md`, any `Resources.txt`-style repo-path file, and every story folder that links back to whatever moved — a silent rename breaks those links without anyone noticing until later.

1. List the project's current top-level contents directly (`Glob`/`ls`), not from memory of a prior read or from what the project's own INDEX claims — the INDEX itself can lag behind the real folder contents (this happened once already: an orphaned duplicate folder sat completely undocumented until a fresh listing caught it).
2. Compare each item against the convention above. Categorize honestly into three buckets, not two — the third bucket matters as much as the first two:
   - **Already matches** — no action needed.
   - **Would rename under the new convention** — e.g. `Meeting Prep/` → `MeetingPrep/`, `700-TOIMPLEMENT-NOTES/` → `ToImplementNotes/`.
   - **Doesn't fit any category in this convention** — flag it and ask, don't force it into the nearest-looking bucket just to make the audit look complete. Some project-specific folders (a repo clone, a zipped snapshot, loose screenshots) are legitimately outside this convention's scope.
3. Present the proposed renames as an explicit before → after list, and for each one, name the specific files that reference the old name and would need updating alongside it. Let the user approve renames individually or all at once — their call, not a forced all-or-nothing choice.
4. Only after approval, execute the approved renames and fix every cross-reference that pointed at an old name. Re-`Glob` afterward to confirm nothing was missed, rather than trusting the plan matched what actually happened.

## Reference templates

- `references/index-template.md` — the `0000-INDEX.md` skeleton: quick-answers table, folder map grouped by category, a conventions section documenting the naming rules above, and the maintenance instruction ("when you add a new folder, add one line here").
- `references/glossary-readme-template.md` — the `Glossary/README.md` skeleton.
- `references/external-documentation-readme-template.md` — the `ExternalDocumentation/README.md` skeleton.
