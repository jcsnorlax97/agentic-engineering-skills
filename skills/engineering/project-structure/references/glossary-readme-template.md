# Glossary — business, domain & industry terms for this project

> **Purpose:** a quick-reference lookup for terms that come up in this project but
> aren't obvious from a software background alone — business/domain concepts,
> industry-specific concepts, and any vendor/partner's own protocol-specific
> vocabulary. Go here first when a term is used and you don't remember exactly what
> it means or why it matters. This is deliberately separate from a code repo's own
> `CONTEXT.md` (if one exists) — that file is the precise *code* domain glossary
> (entities, call boundaries); this one is "what does this business/domain term
> mean and why does this project care," written for someone without that
> background. Cross-reference both ways when a term has both a business meaning
> and a code representation.
>
> **One file per term** (not one growing file) — easier to link to from other docs
> (ADRs, implementation plans, tracker comments) and easier to scan the list below
> to see what's covered.

## Terms

| Term | File | One-line hook |
|---|---|---|
| *(add a row per term as it gets written)* | | |

## How to add a term

New file, `kebab-case-term.md`, one row added to the table above. Cite the actual
source (spec section, entity file, tracker item, conversation with a domain expert,
a legacy doc) wherever possible — don't write from general knowledge alone if a
project-specific source exists, since a specific vendor/industry/team sometimes
uses a term in a narrower or different sense than general usage.

**When does a concept earn its own file, versus staying explained inline inside a
related term's file?** A concept graduates to its own file once it's a distinct
named entity/mechanism (not just a flag or field on another term — a boolean flag
that's literally a field on some other entity should stay inline there, not get
pulled out) referenced from two or more other glossary entries. If a term meets
that bar but doesn't have a file yet, say so explicitly right here in a line like
this — don't leave the gap silent. Periodically re-grep the existing files for
bolded/backticked terms that get referenced across more than one file but have no
entry of their own; that's exactly how a gap like this gets caught before it's been
silently missing for a while.
