# Read a third-party AI-integration tool's actual source before installing it, not just its README/PRIVACY.md

**Captured:** 2026-09-02 — vault-for-founders / claude-obsidian adoption

## Trigger
Before installing the `claude-obsidian` Claude Code plugin (write access
to a real vault), cloned the repo and read the actual source rather than
trusting its own PRIVACY.md/SECURITY.md claims: grepped for every network
call site, traced API-key handling, read the transaction/atomic-write
implementation, and confirmed SECURITY.md's prompt-injection defenses
were real in code, not just documented. Findings matched the docs exactly
in this case, but the check was what earned the trust, not the docs
themselves.

## Rule
Before installing any third-party tool that gets write access to real
data or executes with real permissions (a Claude Code plugin, an agent
skill bundle, a hook), read its actual source for: every network call
site, how secrets/API keys are sourced, what write/mutation safety model
it uses (atomic? rollback? create-only?), and whether it has any explicit
model for untrusted input (prompt injection, in an AI-tool context). A
polished PRIVACY.md is a claim, not evidence.

## Boundary
Proportional to blast radius — a read-only CLI utility with no write
access and no secrets doesn't need this level of scrutiny. Scales with
what the tool is allowed to touch.

## Next step
Candidate addition to `verification-epistemics`, or a new narrow baseline
specifically for adopting third-party Claude Code plugins/skills — check
whether the existing baseline's scope already covers install-time
due-diligence or only in-session verification.
