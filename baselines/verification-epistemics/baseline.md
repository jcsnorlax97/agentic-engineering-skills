# Verification Epistemics Baseline

Status: active
Version: 0.1.0

Always-on discipline for a recurring failure mode: treating an inherited,
paraphrased, or confidently-stated claim as verified fact without checking it
against current ground truth. Distilled from 2026-07 sessions where this
happened via four different vectors — a stale docs branch, a domain-term
paraphrase, a code trace, and a stakeholder's ambiguous feedback — each
producing a wrong conclusion that direct verification would have caught.

## Principles

1. Re-verify an inherited claim against current ground truth before acting on
   it.
   A "confirmed" claim from a prior session, a stale architecture-docs branch,
   or a teammate's description is a starting hypothesis, not a fact — re-check
   it against the actual current code/data before using it to justify an
   action, especially when the system it describes changes quickly or the
   claim crosses a service/repo boundary.

2. Resolve ambiguous domain terms via schema, not prose.
   When two terms look interchangeable in documentation or conversation (e.g.
   two near-synonymous nouns for related-but-distinct concepts), resolve which
   is which by tracing actual entity/foreign-key structure and code, not by
   how consistently a doc uses the words. A coincidental data match (e.g. a
   legacy fixture name) is a prompt to investigate further, not evidence.

3. Use `git log -S <symbol> --all` (pickaxe) to prove "has X ever been true"
   claims.
   When a claim is about whether something has ever existed, been wired up, or
   been called anywhere in a codebase's history, prove it with a pickaxe
   search across all branches rather than inferring it from inspecting the
   current working tree alone.

4. Pair a "no mechanism found" trace conclusion with an empirical check.
   A static code trace that concludes "nothing in the code explains this
   failure" is a hypothesis, not proof — especially for intermittent or
   environment-dependent symptoms. Before presenting that conclusion as a
   verdict, pair it with an empirical re-run or reproduction attempt.

5. Re-read the original request verbatim before implementing feedback framed
   as "make A consistent with B."
   That framing is directionally ambiguous — either side could be the one
   that changes. Re-read the actual original ask before implementing,
   especially once something related has already shipped and the "obvious"
   direction might be backwards.

6. Diff every case against its prior baseline before a bulk-accept.
   Before accepting a batch of approval-test/snapshot regenerations (or any
   bulk-accept operation), diff each changed case against its previous
   baseline rather than trusting the tool's summary. Never run a repo-wide
   bulk-accept when unrelated, already-pending unreviewed artifacts are
   sitting in the same tree — it will sweep them up too.

## Priority

Apply this baseline before presenting a conclusion, a fix, or a summary of
"what's true here," but never use it to override explicit user instructions,
safety rules, privacy boundaries, or stricter repo-local instructions.

## Non-Goals

- This does not require re-verifying every trivial or already-directly-observed
  fact — it applies when a claim is inherited, paraphrased, or crosses a trust
  boundary (prior session, stale doc, another person's description).
- This does not replace domain-specific investigation techniques; it's the
  general discipline underneath them.
