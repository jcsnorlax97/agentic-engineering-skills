# .NET Conventions Baseline

Status: active
Version: 0.4.0

Always-on .NET/C# conventions for dependency-injection registration and
codegen/scaffold output. Distilled from 2026-07 EpinServer work where DI
registration semantics silently dropped a second implementation, and a
scaffolded EF Core migration surfaced changes the agent hadn't caused.

## Principles

1. Use `Add*`, not `TryAdd*`, for every implementation in a multi-implementation
   registration.
   `.NET`'s `TryAdd*` DI methods dedup by service type alone, not
   implementation type. Registering a second implementation of an interface
   meant to be resolved as `IEnumerable<T>` (a strategy-pattern registration)
   with `TryAdd*` silently no-ops — the second implementation is never
   resolved, with no error. Use `Add*` when the interface is intentionally
   multi-implementation.

2. Don't bake a per-call value into a pooled/shared DI instance's registration.
   A typed `HttpClient` (`AddHttpClient<T>()`) assumes a static base URL known
   at DI-registration time. When the real host is resolved per-call (e.g. a
   value read from a database row), do not set `BaseAddress` at registration —
   build the full URI per call instead. This generalizes beyond `HttpClient`:
   any DI-pooled object with a "set-once at registration" value is wrong when
   that value is actually per-call.
   Reinforcement: a `DelegatingHandler` registered via
   `AddHttpMessageHandler<T>()` is pooled, not created per-request. Per-request
   state must flow through `HttpRequestMessage.Options` (or headers), never a
   constructor-injected scoped service treated as if it were set once per call.

3. Treat an unexpected scaffold diff as evidence of pre-existing drift, not
   something you caused.
   When a scaffolded EF Core migration (or any codegen tool) produces changes
   beyond what the intended edit should touch, that is a signal of pre-existing
   model/config drift, not a new problem you introduced. Verify by running a
   throwaway empty re-scaffold — if it reproduces the same unrelated diff, fix
   the root model/config, not the generated output. Never hand-edit the
   generated file to remove the unexpected parts.

4. Implement a cross-cutting concern (audit, retry, validation) as a handler
   registered into an existing pipeline seam, not an opt-in helper method call
   sites must remember to invoke.

5. Place a cross-cutting `DelegatingHandler` relative to a retry handler
   deliberately — inside retry observes physical attempts, outside retry
   observes logical calls.

6. When chaining into a different library's fluent builder mid-pipeline,
   don't cast its return type back — call it as a standalone statement and
   return your own original reference.

7. A fire-and-forget async operation must own its own DI scope, its own
   `CancellationToken.None`, and its own exception handling — never inherit
   any of the three from its trigger.

8. A nullable foreign-key column meaning "no associated record" must receive
   a real `null` end-to-end, never a sentinel or randomly-generated value.

9. In a migration's raw `InsertData`/`DeleteData`/`UpdateData` column
   literals, use the schema's original column casing, never the C# entity
   property's casing.

10. Before a Singleton reaches for `IServiceScopeFactory.CreateScope()` to
    get a fresh handle to a shorter-lived resource, check for a
    purpose-built factory for that resource type first (e.g.
    `IHttpClientFactory`), and use manual scope creation only when none
    exists.

11. Register a `DelegatingHandler` shared across more than one typed
    `HttpClient` via `AddHttpMessageHandler<T>()` as Transient, never
    Singleton.

12. When two options classes bind the same config section, treat one reading
    a property from the other instead of owning its own as a design smell
    to flag during implementation.

13. Before adding a generic type parameter to accept "one of several caller
    types" while preserving encapsulation, check whether the constraint
    interface it requires already does the whole job.
    If the interface used as the generic constraint already exposes every
    member the method needs, the generic buys nothing — skip it. Only
    introduce the generic when the concrete type itself, not just what its
    constraint interface exposes, must flow back out past the method's
    boundary.

14. Before adding a method to a shared strategy-pattern interface, check
    whether sibling implementers treat existing methods as genuine
    capabilities or as permanent unfillable stubs.
    A method intrinsically tied to one implementer's protocol belongs on a
    narrow capability interface instead of the shared one — not on the
    interface every strategy implements. Justify the split with demonstrated
    risk from keeping it shared, not a hypothetical future need.

15. Before naming a new shared abstraction merged from separate call sites,
    check the domain model's existing vocabulary for a narrower established
    meaning tied to only one of the call sites.
    Look at existing status fields, enums, and doc comments before picking a
    name. Prefer a mechanical/structural name over a state-implying one when
    the call sites being merged don't uniformly share that state — reusing a
    status-flavored name that only fits one call site will mislead readers at
    the other.

16. An idempotency/replay short-circuit that finds a record by key must
    separately validate the record's current state (status/expiry) before
    reusing it in a response.
    Existence at that key is not the same as still being valid to reuse. A
    record that once satisfied the request may since have expired, been
    cancelled, or moved to a terminal state; returning it unchecked reuses
    stale data as if it were still current.

17. When auditing every call-site of a conditional credential-routing system
    (e.g. multiple HttpClient configurations), enumerate every method x its
    actual routing rule from the code itself into a full table.
    Read the routing rule from the code, not from memory. Separate the rows
    into "by-design", "correctly exempted", and
    "should-be-exempted-but-isn't" — don't spot-check a handful of call sites
    and assume the rest follow the pattern.

18. When writing/updating a parent and its child in one operation, check the
    ORM model for an existing navigation property before doing a manual
    second save.
    Attach the child to the parent's navigation property before the first
    save so the change tracker resolves the foreign key in one call.

19. Before adding an operation to a versioned/public SDK/API interface,
    confirm a real consumer exists.
    Symmetry or completeness alone is not justification, and new work should
    extend the live interface, not a deprecated parallel one.

20. Don't serialize a value into a shared/generic field only to immediately
    deserialize it back within the next step of the same operation.
    Pass a typed object/property directly; reserve serialization for genuine
    cross-boundary handoffs (cross-process, cross-time, external API).

21. When adding a field to a widely-implemented shared interface, treat a
    green build as the minimum bar, not sufficient proof.
    Separately verify (1) every concrete implementation was actually updated,
    (2) a reflection-based test-data generator targeting the bare interface
    won't fail at runtime for unregistered concrete types, and (3) if the new
    field carries sensitive data, it needs its own masking/redaction tag — it
    does not inherit protection from wherever it was previously nested.

22. A shared "sync whole object graph" update method must not treat a
    missing/null collection on the input object as "clear this in the DB"
    when narrow-purpose callers pass partial objects.
    Narrow callers should re-fetch the full object and mutate only their own
    field, not hand a partial object to a full-sync method.

23. Before attaching a shared request/response logging middleware to an
    HttpClient carrying secrets in the body (e.g. an OAuth client-credentials
    form POST), verify its default masking scope explicitly covers body
    content, not just header names.
    Many masking libraries default to header-only redaction.

24. A migration rollback can only undo migrations whose Down()/reverse code
    is compiled into the branch you run it from.
    If a shared environment's migration history shows entries beyond your
    current branch, locate the branch that actually owns those extra
    migrations (search all branches) and roll back from there.

## Priority

Apply this baseline before ordinary .NET DI and codegen habits, but never use
it to override explicit user instructions, safety rules, privacy boundaries,
or stricter repo-local instructions.

## Non-Goals

- This does not cover general DI lifetime choice (singleton/scoped/transient),
  only the registration-dedup and per-call-value traps above.
- This does not cover EF Core migration authoring or review beyond the
  scaffold-drift signal.
