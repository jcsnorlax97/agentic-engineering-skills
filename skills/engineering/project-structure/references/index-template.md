# <Project Name> — Folder Index

> **Purpose:** this folder accumulates fast. This is the one file to open first to
> find anything else. Last built **<YYYY-MM-DD>**. It's a map, not a status report —
> for current live state (tickets, PRs, deployments), the actual tracker/repo is the
> source of truth.
>
> **Keeping this current:** when you add a new top-level folder, add one line to
> the table in §2. Don't re-summarize a folder's contents here — the folder's own
> entry file (`README.md`, `00-SUMMARY.md`, or similar) should carry the detail. If
> a folder doesn't have an obvious entry file yet, that's a sign it wants one.
>
> **Checking this for staleness:** periodically re-`Glob`/`ls` this project's actual
> top-level contents and diff against §2 below — an index that's never re-checked
> against the real folder listing silently drifts (an orphaned folder went
> undocumented in a sibling project until someone finally did this).

---

## 1. Quick answers — "where do I find…"

| Question | Go to |
|---|---|
| "What does this business/domain/industry term actually mean?" | `Glossary/README.md` |
| Specs, vendor docs, legacy reference material | `ExternalDocumentation/` |
| Latest design-decision / grilling-session output | `Grilling/` (dated subfolders, newest last) |
| *(add rows here as the project accumulates real content — delete this placeholder row once at least one real entry exists)* | |

---

## 2. Folder map

### Fixed reference folders

| Folder | What's in it |
|---|---|
| `Glossary/` | Business/domain term reference, one file per term. `README.md` is the index. |
| `ExternalDocumentation/` | Specs, vendor docs, legacy internal docs — reference material this project doesn't own the content of. |
| `Grilling/` | Design-decision / grilling-session output, one dated subfolder per session (`YYYY-MM-DD-topic/`). |

*(Add rows here as on-demand folders get created — `MeetingPrep/`, `ToImplementNotes/`, `DbNotes/`, `Bugs/`, `SetupNotes/`, or whatever this project actually needs. Reach for one of these names before inventing a new one for the same kind of thing.)*

### Story/ticket folders — `00N-<ticket-id>-<short-kebab-name>/`

One per unit of work, numbered by creation order, ticket-id anchors it back to the tracker.

| Folder | Ticket | What's in it |
|---|---|---|
| *(add a row per story folder as they're created)* | | |

### Root-level loose files

| File | What it is |
|---|---|
| *(loose files that don't fit a folder yet — note what they are and whether they're worth filing into one of the folders above)* | |

---

## 3. Conventions this folder follows (keep doing these)

- **Fixed reference folders** (`Glossary/`, `ExternalDocumentation/`, `Grilling/`, and any on-demand ones) are PascalCase, no number prefix, no spaces — they're singletons, not chronologically ordered relative to each other.
- **Story/ticket folders** are numbered (`00N-<ticket-id>-<short-kebab-name>/`) because creation order genuinely matters for these.
- **This file keeps its `0000-` prefix on purpose** — specifically so it sorts before every PascalCase folder and every `00N-...` story folder in a plain directory listing. That's the one deliberate exception to "fixed folders don't get numbers."
- **Files within any folder** are kebab-case `.md`.
- **New story work → new numbered folder.** Give it an entry file (`README.md` or `00-SUMMARY.md`) if it'll have more than 2-3 files.
- **Cross-cutting, not story-specific** → the on-demand fixed folders above, not a new ad hoc folder.
- **A design-decision / grilling session → a new dated subfolder under `Grilling/`**, not a new top-level dated folder.
