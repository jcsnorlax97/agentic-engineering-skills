# Commit Conventions Baseline

Status: active
Version: 0.1.1

This is a tool-neutral always-on baseline for AI coding agents that write
commits in a repository. It sets the *format* of the commit message: every
commit follows the [Conventional Commits](https://www.conventionalcommits.org/)
specification, with an imperative subject, a body that explains the "why," and
machine-readable footers for tracking references.

It is intentionally generic so it applies to work and personal repositories
alike. Conventional Commits is a public standard, so nothing here is
project-specific; the footer examples simply cover both GitHub issues and Azure
DevOps work items.

## Format

    <type>(<optional scope>): <description>

    [optional body]

    [optional footer(s)]

## Allowed types

- `feat` — a new feature
- `fix` — a bug fix
- `docs` — documentation only
- `style` — formatting, whitespace, no logic change
- `refactor` — a code restructure that is neither a fix nor a feature
- `test` — adding or correcting tests
- `chore` — build process, tooling, or dependency updates
- `ci` — CI/CD configuration changes

## Rules

1. Use present-tense imperative mood.
   "add feature", not "added feature" or "adds feature".

2. Keep the subject line to 72 characters or fewer.
   No trailing period. Scope is optional but encouraged in larger codebases.

3. Explain the why in the body.
   When the change is not self-evident, add a body after one blank line and
   wrap prose at roughly 72 columns. Describe intent and consequences, not a
   restatement of the diff.

4. Reference tracking items in the footer.
   `Closes #123` for a GitHub issue, `AB#12345` for an Azure DevOps work item.

5. Flag breaking changes explicitly.
   Append `!` after the type/scope (`feat(api)!: ...`) or add a
   `BREAKING CHANGE:` footer describing the break.

## Examples

    feat(auth): add OAuth2 login support
    fix(api): handle null response from upstream service
    docs: update README with setup instructions
    chore(deps): bump typescript from 5.3 to 5.4
    refactor(orders)!: remove deprecated pricing export

    BREAKING CHANGE: LegacyPricing is no longer exported; use PricingV2.

## Priority

This baseline takes precedence over ordinary commit habits, but never use it to
override explicit user instructions, safety rules, privacy boundaries, or
stricter repo-local instructions. If a repository already defines and follows
its own commit convention, follow that instead.

## Non-Goals

- This governs message *format* only. It composes with, and does not replace,
  the `git-collaboration-hygiene` baseline (stage explicit paths, review the
  staged diff, keep remote operations consent-based) and the
  `commit-attribution` baseline (no AI co-author trailers or "generated with"
  footers).
- This does not govern branch naming (see the `branch-naming` baseline), PR
  descriptions (see the `pr-description` baseline), changelogs, release notes,
  or versioning policy.
- This does not require or forbid any specific commit-linting tooling; it
  describes the message the agent should write.
