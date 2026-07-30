# .NET Conventions Baseline

Status: active
Version: 0.1.0

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

3. Treat an unexpected scaffold diff as evidence of pre-existing drift, not
   something you caused.
   When a scaffolded EF Core migration (or any codegen tool) produces changes
   beyond what the intended edit should touch, that is a signal of pre-existing
   model/config drift, not a new problem you introduced. Verify by running a
   throwaway empty re-scaffold — if it reproduces the same unrelated diff, fix
   the root model/config, not the generated output. Never hand-edit the
   generated file to remove the unexpected parts.

## Priority

Apply this baseline before ordinary .NET DI and codegen habits, but never use
it to override explicit user instructions, safety rules, privacy boundaries,
or stricter repo-local instructions.

## Non-Goals

- This does not cover general DI lifetime choice (singleton/scoped/transient),
  only the registration-dedup and per-call-value traps above.
- This does not cover EF Core migration authoring or review beyond the
  scaffold-drift signal.
