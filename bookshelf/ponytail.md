---
title: ponytail (DietrichGebert/ponytail)
url: https://github.com/DietrichGebert/ponytail
kind: skill-repo
captured: 2026-08-26
status: unprocessed
---

Ruleset/plugin that pushes AI coding agents toward simpler, smaller, less
over-engineered solutions — before writing new code it checks whether the
feature is needed at all, whether the standard library or platform already
covers it, or whether an existing dependency does the job. Commands:
`/ponytail [lite|full|ultra|off]`, `/ponytail-review` (diff over-engineering
check), `/ponytail-audit` (repo-wide scan), `/ponytail-debt`, `/ponytail-gain`.

Install: `/plugin marketplace add DietrichGebert/ponytail` then
`/plugin install ponytail@ponytail`.

Surfaced in an Instagram roundup of 5 Claude Code repos. Conceptually
overlaps with this toolkit's own `karpathy-principles` baseline
(simplicity-first, surgical changes) — worth diffing rule sets against it
before ever importing anything from here.
