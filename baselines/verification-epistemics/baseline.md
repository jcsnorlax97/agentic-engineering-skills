# Verification Epistemics Baseline

Status: active
Version: 0.2.0

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

7. Search across every locally-known repo before trusting cwd-only evidence
   for a pasted artifact or an unfamiliar file.
   When a user pastes a log line, error, stack trace, or config key with no
   stated source, grep its literal, distinctive text across every repo known
   to be checked out locally before analyzing based on the shell's current
   working directory. When an unfamiliar, tool-generated file turns up (a
   crash dump, lock file, cache artifact), check whether the same filename
   exists in other, untouched local repos before treating it as caused by
   the current session — a hit in unrelated repos points to a systemic or
   environmental cause instead.

8. Read a component's originating ticket scope before inferring its purpose
   from code structure alone.
   When a pipeline or component's name, position, or apparent behavior
   suggests a specific purpose that matters for a conclusion being reported,
   find and read its originating story/ticket's Scope, Out of Scope, or
   acceptance-criteria section — explicit scope statements are more reliable
   than structural inference, since code can legitimately look like it does
   more than it was ever asked to do.

9. Decompile a closed-source dependency's shipped assembly before asserting
   whether it supports a specific capability.
   When a design decision depends on whether a compiled package emits a
   signal, calls a callback, or defaults a value, and the docs are silent or
   ambiguous, decompile the actual shipped assembly (e.g. `ilspycmd`) rather
   than inferring from framework conventions or a similar library's
   behavior. Decompiling answers what a method's own logic does, not which
   runtime instances get shared across component boundaries — verify
   cross-component wiring by running the code, not by reading further
   decompiled output.

10. Do a deliberate side-by-side DRY pass after writing near-duplicate
    wiring for two or more similar call sites.
    After writing wiring, configuration, or registration code for two or
    more structurally similar call sites in the same task, before calling
    the task done, compare the new blocks side by side for duplication worth
    extracting — each block reads as correct and self-contained in
    isolation at write-time, so the duplication is only obvious once
    compared directly.

11. Trace where a "local" or "dev" environment config actually resolves its
    secrets before running anything that writes data through it.
    An environment named `local` or `dev` is not necessarily isolated — grep
    the startup/config-provider chain to see whether it bottoms out in
    hardcoded local values or a real, shared cloud secret store. If it
    resolves to a real shared resource, say so explicitly and get
    confirmation before running any operation that writes data through it.

12. Trust runtime evidence over code-only inference when they conflict, then
    widen the code search to cross-cutting layers.
    When a user or existing evidence (trace screenshots, logs) contradicts a
    conclusion reached by reading handler-level code, treat the runtime
    evidence as authoritative and widen the search to middleware,
    interceptors, base classes, or compiled dependencies with no local
    source — a grep of only the repo's own source can miss both
    cross-cutting registration code and anything shipped as a compiled
    package.

13. Give a subagent dispatched for read-only investigation explicit
    destructive-command restrictions or worktree isolation, not prose
    framing alone.
    Before dispatching a subagent for investigation intended to be
    side-effect-free, check what tools its agent type actually grants — an
    agent type that excludes Edit/Write can still retain Bash. Either
    enumerate forbidden command patterns in the prompt (no `rm`, `mv`,
    `git add/commit/push/reset`, no file writes) or run it with
    `isolation: "worktree"` when an accidental mutation would matter.

14. Verify who wrote a code comment or doc before citing it as evidence to a
    third party.
    Before citing a comment, migration note, or doc as justification for a
    claim to someone with no context on its origin, check its authorship
    (`git blame` / `git log -1`). If the author is the same person making
    the current argument, present it only as the current proposal, never as
    an independently validated constraint.

15. Confirm a config file is actually git-tracked before repurposing it to
    point at a remote or shared environment.
    A filename convention like `.local.` is not a reliable signal of
    git-ignored status — run `git check-ignore -v <file>` or
    `git log -- <file>` before editing a config file to temporarily hold a
    real connection string, secret, or hostname, and plan the revert step
    before making the edit, not after.

16. Verify behavior that only emerges from several real components wired
    together with a throwaway harness on the real production wiring.
    When a behavior can't be proven by any single component's unit tests,
    build a disposable harness that wires everything together exactly as
    production does, substituting only the one component that can't be
    safely or deterministically exercised (an external system, a
    production-only destination). This proves composition, not just
    isolated correctness, and can also disprove an already-agreed plan
    before any production code is written.

17. Run `git remote -v` before choosing which PR or issue-tracking tool to
    query for a repo.
    Don't infer a repo's hosting platform from adjacent context (a
    company's other tooling, a pipeline name, prior session memory) — a
    repo's source and PRs can live on one platform while its CI pipelines
    or work items live on another. Check each repo's remote individually
    when a task spans multiple repos, since siblings in the same
    initiative can differ.

18. Cross-check an issue tracker's status field against actual git merge
    history before reporting status.
    A ticket's tracked state (e.g. "In Test," "Ready") can lag a real merge
    because updating it is a manual step nobody remembers — grep the repo's
    merge-commit history for the ticket ID before reporting status. If
    tracker and code disagree, state both explicitly rather than treating
    the tracker as automatically authoritative.

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
