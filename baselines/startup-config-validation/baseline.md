# Startup Config Validation Baseline

Status: active
Version: 0.1.0

Always-on fail-fast posture for configuration validation in services. Applies
to any application that reads configuration from environment variables, config
files, Key Vault, or similar sources.

Distilled from production .NET service incidents where missing secrets or
misconfigured API URLs reached production and surfaced as confusing runtime
errors on the first request — rather than as a clean startup failure visible
in CI and deployment smoke tests.

## Principles

1. Validate all required config at startup.
   Read and throw on every required configuration value — connection strings,
   API base URLs, auth credentials, Key Vault names, external service endpoints
   — during service registration or app build, before the app starts serving
   requests. A missing value must surface as an immediate startup failure, not
   as a null reference or silent default on first use.

2. Use ?? throw as the validation pattern.
   The standard form is:
   `var value = builder.Configuration["Section:Key"]
       ?? throw new InvalidOperationException("Section:Key is not configured.");`
   Do not silently default to empty string, null, or a fallback URL. The failure
   message should name the exact config key so operators know immediately what
   to fix.

3. Validate presence, not content.
   Check that the key exists and is non-empty. Do not validate format, URL
   reachability, or credential correctness at startup — only that the value is
   present. Format errors are caught early enough by the first real operation.

4. Exclude optional values.
   Do not validate config keys that have safe in-code defaults or that are
   intentionally absent in some environments. Only keys whose absence would
   cause a silent failure or confusing error belong in startup validation.

## Priority

Apply this baseline before ordinary service-setup habits, but never use it to
override explicit user instructions, safety rules, privacy boundaries, or
stricter repo-local instructions.

## Non-Goals

- This is not a requirement to validate config format or semantics at startup.
- This does not require health-check endpoints to re-validate config on every
  request.
- This does not define what configuration system to use (appsettings, env vars,
  Key Vault, etc.).
