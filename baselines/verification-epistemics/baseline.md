# Verification Epistemics Baseline

Status: active
Version: 0.4.0

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

19. Check the opposite cardinality direction before closing a single-result
    assumption bug.
    When a `.First()`, `.Single()`, or indexing assumption is found broken
    because a call site unexpectedly hit zero or multiple results in one
    direction, explicitly check whether the opposite direction (e.g.
    many-to-one vs. one-to-many) is also reachable at the same call site
    before considering the bug fully diagnosed — fixing only the observed
    direction can leave the mirror-image failure live.

20. Treat a check-in-style confirmation question as a prompt to genuinely
    re-verify, not a request to recap the last action.
    When asked a check-in-style confirmation question ("is X up to date?",
    "did we handle Y properly?"), treat it as a prompt to actually re-verify
    the relevant area against current ground truth, not just to confirm the
    most recent single action taken — the asker is usually probing for
    drift or gaps, not asking for a recap.

21. Confirm which open question a piece of untargeted evidence answers
    before citing it as confirmation.
    When evidence (a screenshot, log, or error text) arrives with no stated
    target and more than one question is genuinely open, confirm which
    specific question it answers before asserting it confirms any
    particular claim — evidence that settles one open question can be
    silently misapplied to a different one it says nothing about.

22. Break a stalled qualitative trade-off debate by finding one concrete,
    verifiable fact.
    When a qualitative architecture or design trade-off debate loops more
    than a round or two without converging, stop arguing the abstract
    merits and go find one concrete, directly verifiable fact (a benchmark,
    a spec detail, existing precedent in the codebase) that could reframe
    the question — a stalled debate is often a missing fact wearing the
    costume of a values disagreement.

23. Triangulate a high-blast-radius claim across independent channels
    before treating it as confirmed.
    When a broad, high-blast-radius claim rests on a single piece of
    confirming evidence, triangulate independently across multiple
    channels (code, cross-repo/history search, team chat) before treating
    it as confirmed, scaling the amount of triangulation to the claim's
    stakes — one source agreeing with itself is not independent
    confirmation.

24. Verify the exact operation against the authoritative primary spec, not
    just that some test or summary exercises "an" operation.
    A working test artifact or a confident secondary summary that
    exercises *an* operation is not evidence it's the *specific correct*
    operation for a stated question — verify against the authoritative
    primary spec by exact name/verb match before concluding the right
    operation was used.

25. Verify a governance/compliance requirement's literal trigger condition
    before raising it as a blocker.
    Before raising a documented governance or compliance requirement as a
    blocker on a newly built mechanism, verify its literal trigger
    condition rather than generalizing from its apparent intent — a rule's
    spirit can sound broader than the specific condition that actually
    activates it.

26. Check every hop of a multi-repo/multi-deployable integration
    independently before declaring a fix complete.
    When verifying whether a value survives a multi-hop integration
    spanning several repos or deployables, check every hop independently —
    not just the first one found broken — before concluding the fix is
    complete, since a value can silently drop or get overwritten at a later
    hop even after the first break is patched.

27. Verify server-side that a scaffolded form field actually flows through
    before presenting it as editable.
    Before presenting a field as editable in a scaffolded create/update
    form, verify server-side that it actually flows through unmodified
    rather than being silently overridden or derived — a form control
    rendering and submitting successfully is not proof the backend honors
    the value it carries.

28. Decompose a multi-layer call chain into layers when verifying an
    edge-case input is safe.
    When verifying an edge-case input is safe across a multi-layer or
    multi-service call chain, decompose the chain into its individual
    layers and check each one for named, concrete risk patterns (injection,
    overflow, encoding mismatch) rather than reasoning generally that the
    input is "naturally safe" — safety at one layer doesn't imply safety at
    the next.

29. Verify a vendor's own definition directly when an internal construct's
    name resembles their spec term.
    When an internal construct's name resembles a term used in an external
    vendor's own specification, verify the vendor's actual definition
    directly from their primary-source document rather than assuming
    shared meaning from name similarity — the same word can mean
    structurally different things across an internal codebase and a
    vendor's spec.

30. Rule out a stale credential before granting new permissions on the
    first auth failure after a routing change.
    On the first auth failure immediately following a credential-routing
    change, rule out a stale pre-change token or credential still cached
    somewhere in the chain before granting new permissions — the fastest
    fix for a routing change's first failure is often clearing stale state,
    not widening access.

31. Code archaeology escalation ladder: search the org wiki for GUI-only
    admin mechanisms before concluding a field's purpose is unknowable.
    When current code plus retired or superseded implementations don't
    fully explain a field's or mechanism's purpose, search the org's
    internal wiki for GUI-only admin/setup mechanisms (settings configured
    through an admin panel with no corresponding code) before concluding
    the answer is unknowable — this is the last rung of the code-archaeology
    ladder, after current code and history, not a first resort.

32. Search existing notes for prior coverage before finalizing output built
    from fresh research.
    Before finalizing any output built from fresh research (a new note, a
    conclusion, a recommendation), search the relevant existing notes or
    vault areas for prior coverage of the same specific question — fresh
    research that duplicates or silently contradicts an existing note is a
    gap worth catching before publishing, not after.

33. Load and apply a stored feedback/mistake memory before an action known
    to have one, not as a post-hoc check.
    Before performing an action type known to have a stored feedback or
    mistake memory associated with it, load and apply that memory
    proactively before taking the action, not as a post-hoc check
    afterward — checking after the fact catches the mistake only once it
    has already been made again.

34. Run a parameterized, re-run-until-zero-new-hits sweep when clearing a
    whole surface, not a single ad hoc pass.
    One ad hoc pass or grep is not proof of completeness when sweeping a
    whole surface for remaining references or artifacts (removing a
    deprecated subsystem, finding all stranded commits across remote
    branches) — run a parameterized sweep across the full surface and
    re-run it until it returns zero new hits, instead of treating one
    incremental ad hoc check as sufficient.

35. Immediately after fixing a bug in a specific category, deliberately
    re-review the next new code you write for that same category.
    Having just fixed one instance of a missing null check, boundary
    check, or similar category of bug doesn't make you immune to writing
    another instance of it minutes later — consciously re-review the next
    new code you write for the same category rather than assuming the fix
    itself raised your guard.

36. Use diff shape as the first signal when attributing an unexpected
    output-field change to code vs. data.
    When a field's value changes unexpectedly, check whether the diff is
    absent→present or value→value before investigating further:
    absent→present usually means a code/schema change (trace the commit
    that added the field), while value→value usually means a data/config
    change (check the record's updated/editor metadata) — this narrows
    where to look before spending time on the wrong side.

37. When credible sources conflict on a number, identify the differing
    methodology or scope before presenting a figure.
    Don't silently pick one source over another — identify the
    differing methodology or scope behind each figure first, then
    present both figures side by side with their scope labeled, so the
    reader can see why they diverge instead of receiving a single
    unexplained number.

38. Don't infer whether code is legacy or dead from its name or folder
    location alone.
    A name like `_deprecated` or a folder called `legacy/` is a hint, not
    proof — verify via git-blame recency, the config's actual default
    value, and real usages/wiring in the target environment before
    removing or disabling it.

39. To judge whether a running process or build reflects a source change,
    compare mtimes and process-start time as objective evidence.
    Compare source file mtime vs. build-artifact mtime vs. process-start
    time to determine whether a running process or build actually
    reflects a given source change, rather than guessing from a
    stale-looking screenshot or the developer's memory of when they last
    deployed.

40. Verify an enumerable identifier against the host's actual runtime
    registry, not the SDK's declared type or a reference prototype.
    For an enumerable identifier accepted by a validating host (an icon
    name, a capability flag, a widget type), check the host's actual
    runtime registry or enum rather than trusting the SDK's declared type
    or a reference prototype — the SDK type is typically an upper bound
    on what the host actually accepts, not a guarantee every listed value
    works.

41. Assess missing or substituted data's impact by the model's sensitivity
    to the specific missing segment, not by the proportion missing.
    A small percentage of missing tail or extreme values can bias tail
    statistics far more than their share of the dataset would suggest —
    judge impact by what the analysis is sensitive to, not by treating a
    low missing-data percentage as automatically low-risk.

42. Hold a half-remembered citation as a flagged, unconfirmed note until
    the original source is traced and confirmed.
    A half-remembered citation ("I recall X said...") is a
    human-sourced, non-canonical claim — never promote it into a durable
    rule or policy until you've traced it back to and confirmed the
    original source; until then it stays a flagged, unconfirmed note.

43. Treat a conveniently exonerating or preferred-conclusion root-cause
    explanation as a signal to raise the verification bar.
    When a root-cause explanation conveniently exonerates the code under
    test, or happens to match the conclusion you were hoping for, treat
    that as a reason to raise the verification bar rather than lower it —
    trace the actual execution path before dismissing the issue on the
    strength of a convenient explanation.

44. Diff two structurally similar call chains layer by layer, not just
    at the outer layers, when a feature breaks via one but not the other.
    When a feature breaks only through a new API entry point that looks
    structurally identical to an old, working one, diff the two full call
    chains (entry → dispatch → resolver) layer by layer rather than
    stopping the comparison once the outer layers look alike — the
    divergence is often deeper in the chain.

45. Enumerate every producer's actual value domain from the code before
    fixing a shared field's type based on one crashing call site.
    Before fixing a shared field's type based on the one call site that
    crashed, enumerate every producer's actual value domain directly from
    the code, and design the fix to cover the full domain rather than
    just the observed crashing case.

46. Rank competing root-cause candidates by precise timestamp correlation
    strength, not by which sounds like a familiar failure mode.
    When two root-cause candidates both fit the overall timeline, rank
    them by precise timestamp correlation strength (minutes vs. hours,
    drawn from independent sources) rather than by which one sounds more
    like a familiar technical failure mode.

47. Treat "the same input succeeds on another record" as a signal to look
    for an overwrite, not for missing reference data.
    When the same input succeeds on another record but fails on this one,
    redirect diagnosis away from "missing reference data" and toward "a
    later operation overwrote or wiped this specific record" — success
    elsewhere with identical input rules out a systemic data gap.

48. Check template or checklist compliance section-by-section against the
    literal template text, not by an overall skim.
    Compare each section of the deliverable against the literal template
    text one at a time rather than skimming the whole document for a
    general impression; a user's "please re-check" request is itself a
    signal to switch from skim to a literal, section-by-section pass.

49. After renaming or moving a source location, resolve — not just list —
    each downstream pointer to confirm the target actually exists.
    After renaming or moving a source location that others point at,
    actually resolve each downstream pointer to confirm the target
    exists, rather than just listing the pointers and confirming they
    have the correct type — a correctly typed link does not mean it
    resolves.

50. Re-check each pipeline stage's scope against the original requested
    scope, not just against the previous stage's output.
    When threading an extraction or filter's scope through a multi-stage
    pipeline, re-check each stage against the *original* requested scope
    rather than only against the previous stage's output — scope can
    silently narrow or drift from stage to stage even when each
    individual transition looks correct.

51. Search your own team's existing tickets and records before assuming a
    question requires an external party or another team.
    Before assuming a piece of information requires reaching out to an
    external party or another team, search your own team's existing
    tickets and records first — the answer may already be documented
    there.

52. Individually verify cross-cutting concerns unrelated to a migration's
    stated theme when auditing whether it's complete.
    When auditing whether a migration or rollout is complete, individually
    verify cross-cutting concerns unrelated to its stated theme (auth
    mechanism, routing, secrets) — completing the migration's named scope
    does not imply those were updated too. This also covers the sibling
    case: a downstream service 404ing for a specific tenant despite
    correct provider/integration-layer config may indicate a separate,
    independent "tenant onboarding" step — check for it as its own
    precondition rather than assuming the provider-layer config is
    incomplete.

53. Check the DNS zone for a wildcard record before treating successful
    resolution as evidence a hostname was ever used.
    A hostname resolving successfully via DNS is not evidence it was ever
    used — check the zone for a wildcard (`*.domain`) record before
    treating resolution as proof of use, and verify actual use via access
    logs or the owning team instead.

54. When a spec reads as functionally identical for two similar options
    even after a re-read, check an adopter's own documentation instead.
    When a spec's prose reads as functionally identical for two similar
    options even after a re-read, stop re-reading the spec and check
    whether an adopter's own (non-spec-author) documentation has already
    made and consistently applied a classification between them.

55. Run a closeout/retrospective review pass against a fixed multi-category
    checklist every time, not a single-direction scan.
    A closeout or retrospective review pass needs a fixed multi-category
    checklist (unclassified statements, session self-inconsistency,
    dedup-vs-existing-records) run every time, not a single-direction
    scan repeated only until someone asks "anything else?"

56. Scope a severity downgrade explicitly to the one finding it applies
    to; don't let softened tone bleed across a batch.
    When new evidence downgrades the severity of one finding in a batch of
    similarly-reported findings, scope the downgraded language explicitly
    to that one finding and state that the others retain their original
    severity — don't let softened tone bleed across the whole batch by
    default.

57. Reproduce a reported symptom directly, confirm it, fix it, then
    re-run the same reproduction — a proxy check is not a substitute.
    Before shipping a fix for a reported-but-not-directly-observed
    symptom, build a direct reproduction of the exact failure, confirm it
    shows the problem, then re-run that *same* reproduction after the fix
    — a plausible proxy check on an adjacent code path is not a
    substitute for re-triggering the original symptom.

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

## Editorial note

This baseline has grown very large (57 principles) across two consolidation
passes in one day. It likely needs a structural/consolidation pass —
grouping principles into sub-categories and merging near-duplicates —
before further additions. Flagging this for a future maintainer; not
acted on here.
