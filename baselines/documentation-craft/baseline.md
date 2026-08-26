# Documentation Craft Baseline

Status: active
Version: 0.1.0

Always-on discipline for documentation structure, mechanics, and prose-style
decisions — how a document is organized, linked, scoped, and worded. This is
a distinct concern from `code-doc-sync`, which is about keeping documentation
synced to actual code/system behavior, and from `handoff-doc-discipline`,
which is about the living-document lifecycle of a single resume/plan file
that gets edited in place. This baseline applies whenever the agent is
writing, restructuring, relocating, or reviewing documentation of any kind —
independent of whether that documentation happens to describe code.

## Principles

1. Turn an in-prose recommendation to edit a different file into an action or
   a tracked item, not just a sentence.
   Before requesting review, if a response recommends an edit to a different
   file than the one being written, either make that edit immediately or
   explicitly track it as an open item somewhere it will be re-surfaced (a
   TODO list, an issue, a tracked-items section). A recommendation written in
   one document's prose is not itself a completed action, and prose
   recommendations buried in an unrelated document are the easiest kind of
   follow-up to lose.

2. Verify link integrity with a script after moving or renaming cross-linked
   markdown files, and re-check every file that was touched.
   After moving or renaming cross-linked markdown files, verify link
   integrity with a script that resolves every relative link target — don't
   rely on memory of what was touched. Re-check every file that WAS touched,
   not just the ones the move intended to reference, for over-broad
   find/replace corruption of unrelated links; a global search-and-replace
   run to fix the intended links can silently mangle an unrelated link that
   happened to share the same substring.

3. Recognize a request spanning or sequencing multiple existing units as a
   shift in information grain, and create a new parallel category instead of
   forcing it in.
   When a follow-up documentation request spans or sequences multiple
   existing units rather than adding depth to any single one, recognize it as
   a shift in information grain (e.g. from "detail on one thing" to "an index
   or sequence across several things") and create a new parallel category or
   document instead of forcing it into an existing file. Stuffing a
   cross-cutting concern into one of the units it cuts across leaves it
   discoverable from only one of the places a reader would look.

4. Place general system knowledge in the producer's repo, and keep only
   tool-specific content in the consumer's repo.
   When writing or relocating documentation that spans "how the system
   generally works" and "how this one tool/consumer uses it," place general
   system knowledge in the producer's repo (linked from the consumer) and
   keep only tool-specific content in the consumer's repo. Decide this
   per-section, using the test "would this be equally true for a different
   consumer of the same system?" — not by where the need for the doc first
   arose. A section that would read identically if written for any other
   consumer belongs with the producer.

5. Default user- and support-staff-facing documentation to minimum-necessary
   wording, recursively.
   Default all user- or support-staff-facing documentation to
   minimum-necessary wording — word over phrase, phrase over clause, clause
   over sentence — applied recursively at every level of the document, not
   just at the sentence level. This is distinct from durable audit/decision
   records (ADRs, incident writeups, handoff docs), where completeness
   matters more than brevity and this default does not apply.

6. Keep an inline bug-fix comment to a short "does X — previously did Y"
   statement; move audit-trail evidence elsewhere.
   Inline bug-fix code comments should be a short "does X — previously did
   Y" statement in 1-2 sentences, with no duplicated phrasing and no
   ambiguous reused terms between the "does" and "previously did" halves.
   Move full audit-trail/cross-validation evidence (what was tested, what
   confirmed the bug, links to the investigation) to a separate durable doc —
   never inline in the comment itself, where it outlives its usefulness and
   clutters the code it's attached to.

## Priority

Apply this baseline whenever writing, restructuring, relocating, or reviewing
documentation, but never use it to override explicit user instructions,
safety rules, privacy boundaries, or stricter repo-local instructions —
including a repo's own more specific documentation conventions.

## Non-Goals

- This does not cover keeping documentation synced to actual code or system
  behavior — see `code-doc-sync`.
- This does not cover the lifecycle of a living, in-place-edited
  handoff/resume/plan document — see `handoff-doc-discipline`.
- This does not mandate a specific documentation tool, static-site generator,
  or file-naming scheme; it applies regardless of the toolchain.
- Principle 5's brevity default does not apply to audit trails, incident
  writeups, ADRs, or other durable decision records, where completeness is
  the priority.
