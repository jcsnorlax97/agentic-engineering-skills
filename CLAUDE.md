# Claude Project Instructions

Use traditional Chinese unless the user explicitly asks for another language.

## Project Purpose

This repo stores reusable AI agent assets: skills, baselines, workflow
definitions, agent role packs, and supporting templates. Treat `skills/` as the
canonical source for invoked skills. Treat `.claude/skills/` as the Claude Code
project adapter.

Treat `baselines/` as the canonical source for always-on baseline
packs that can be applied to repo instruction files through managed blocks.

Reusable candidate skills may live here. Record their lifecycle status,
confidence, evidence, and promotion decisions in
`docs/skills-inventory.yaml` (this repo's skills only; split from the frozen
skillops repo on 2026-07-03).

## Porting Lessons From Employer-Specific Work

Durable technical or process lessons learned during employer-specific work
(e.g. via that employer's own internal AI-toolkit repo) still have portable
value and belong here too, in generic form — even though the originating
work happened in a repo that won't travel to the next employer.

- Keep the underlying technology/process fact: a database engine's locking
  behavior, a DI framework's registration semantics, a git/PR hygiene habit,
  a general debugging discipline.
- Strip employer-specific detail first: company name, internal service or
  repo names, ticket IDs, proprietary system details, or anything that would
  identify the employer or its systems.
- If what remains is genuinely portable, mirror it here even though its
  twin also lives in an employer-specific toolkit — this repo is the one
  that survives an employer change, that one doesn't.
- Never record employer-proprietary information here, even redacted or
  paraphrased, if there's real doubt about whether it's confidential — leave
  it out and ask first.

## Required Context

- Read `CONTEXT.md` before creating, renaming, or substantially changing skills.
- Read `docs/reference/repo-layout.md` and `docs/specs/0001-cross-tool-skills-repo.md` before changing repository layout or install behavior.
- Use `docs/adr/0000-template.md` for decisions that are hard to reverse and need future context.

## Skills

The following skills are imported from `mattpocock/skills`; preserve attribution
in `NOTICE.md` and `docs/upstream-sources.md` when changing or refreshing them.

- Use `/diagnose` for disciplined debugging and performance regression work.
- Use `/grill-with-docs` when plans need to be challenged against domain language and ADRs.
- Use `/improve-codebase-architecture` for architecture review and refactoring opportunities.
- Use `/prototype` for throwaway design or UI experiments.
- Use `/setup-matt-pocock-skills` when a downstream repo needs agent-skill configuration.
- Use `/tdd` for test-first feature or bug-fix work.
- Use `/to-issues` to split a plan or PRD into independently grabbable issues.
- Use `/to-prd` to turn conversation context into a PRD.
- Use `/triage` to classify and move issues through workflow states.
- Use `/zoom-out` when the current code or plan needs broader context.

The following skills are local additions in this repository.

- Use `/grill-spec` when requirements are unclear and no concrete plan exists yet; it ends with a first vertical slice. For challenging an existing plan against docs, use `/grill-with-docs` instead.
- Use `/methodology-intake` to classify external methodology sources before promoting them into repo artifacts.
- Use `/setup-agent-team` to create a bounded manual execution packet for multi-domain, parallelizable, context-heavy agent-team work, or to refuse when single-agent work is more appropriate.
- Use `/staff-level-review` for reviews that need a fixed findings/verdict contract, a review context bundle, or a non-GitHub diff source; for routine local diff review prefer the built-in `/code-review`.
- Use `/client-flow-diagrams` to create or revise high-level workflow, process, or integration diagrams for client or non-technical audiences.
- Use `/query-azure-devops` to query Azure DevOps work items and pull requests via the Azure CLI.
- Use `/social-live-photo-card` to turn user-provided media into a social-platform Live Photo card.

Retired local skills (see `docs/adr/0002-no-parallel-thin-skill-variants.md`):
`ship-vertical-slice` (use `/tdd`) and `diagnose-regression` (use `/diagnose`).
Do not recreate thin local variants of imported skills.

## Verification

Run this after skill or layout changes:

```bash
./scripts/skills-setup/verify.sh
```

Run this after portable baseline changes:

```powershell
./scripts/baseline.ps1 verify
```

## Safety

- 禁止批量刪除文件或目錄。
- Do not use `rm -rf`, `rmdir /s`, `rd /s`, `del /s`, or `Remove-Item -Recurse`.
- Delete only one explicit file path at a time when deletion is necessary.

<!-- BEGIN baseline:karpathy-principles v0.2.0 -->
## Portable Agent Baseline: Karpathy Principles

- Think before coding: state assumptions, surface ambiguity, and ask when the safe interpretation is unclear.
- Simplicity first: prefer the smallest design that satisfies the request; avoid speculative abstractions or extra configuration.
- Surgical changes: touch only files and lines needed for the task, match local style, and mention unrelated concerns instead of editing them.
- Goal-driven execution: turn open-ended work into success criteria and verify the result with tests, scripts, inspection, or another concrete check.

This baseline takes precedence over ordinary implementation habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:karpathy-principles -->


<!-- BEGIN baseline:layered-ownership v0.2.0 -->
## Portable Agent Baseline: Layered Ownership

- Each repo or layer records its own decisions, status, and roadmap; do not write another layer's decisions into this repo's documents.
- Cross-layer references are pointers, not ownership: link to the owning repo's artifact instead of duplicating or governing it.
- Before recording a status or decision entry, identify which layer owns the affected asset and record it in that layer's own documents.
- Do not create or grow a central governance hub; if a document starts mirroring another repo's changes, stop and move the content to its owner.

This baseline takes precedence over ordinary documentation habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:layered-ownership -->

<!-- BEGIN baseline:process-vs-work-doctrine v0.2.0 -->
## Portable Agent Baseline: Process-vs-Work Doctrine（何時加流程、何時直接做事）

流程的預設答案是「不要」。想建新 repo、skill、spec、自動化或治理層時，先過以下七關；過不了就直接做事。引用本準則擋下違規提案是正當行為。

1. 痛先於流程：同一種失敗有兩次日期可指之前，不建流程、repo、skill 或 spec。
2. 加一層必先殺一層：新 meta 層必須指名它取代誰；meta repo 淨數不得上升（產出型 repo 不在此列）。
3. 三次使用前只准最簡形式：不得有自己的 repo、spec 目錄、install script 或 CONTEXT.md。
4. 只寫不讀即是死：持續寫入的紀錄 60 天沒被任何決策引用即預設凍結（ADR、audit、handoff 等點狀決策紀錄不在此列）。
5. 凍結就是凍結：解凍需指出今天被擋住的真實任務；「可以更完整」不是理由（只修凍結層的誤導性錯誤不算解凍）。
6. 一個 session 能做完的事，不准先搭鷹架：自動化與包裝腳本要等同樣的事第二次出現。
7. Meta 配額：連續 meta session 不得超過 1 個，開始前必須指出服務的下一個實際產出任務（執行已裁決 ticket 與例行維護不佔配額）。

全文與快速判斷表見 ai-toolkit `baselines/process-vs-work-doctrine/baseline.md`。

This baseline takes precedence over ordinary planning habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:process-vs-work-doctrine -->

<!-- BEGIN baseline:code-doc-sync v0.2.0 -->
## Portable Agent Baseline: Code-Doc Sync

- Check docs before closing: when a repo has architecture docs and a task changes externally observable behavior or a contract other code depends on (a public API, a documented flow, a class relationship that appears in diagrams), check the docs that describe the changed behavior and decide explicitly whether each needs updating; skipping the check is not acceptable even for bug fixes. Purely internal changes with no observable-behavior or contract impact do not require it.
- Show the concrete runtime type: in flow diagrams and call traces involving virtual or abstract methods, use the concrete class name that executes at runtime, not the abstract declaration site — writing the base class name hides the polymorphism the diagram is meant to explain.

These principles are folder-name-agnostic. If the repo specifies where documentation lives (in CLAUDE.md, README, or a project-specific section), read that first. If no documentation is found, these principles fire on nothing — that is acceptable.

This baseline takes precedence over ordinary implementation habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:code-doc-sync -->

<!-- BEGIN baseline:git-collaboration-hygiene v0.3.0 -->
## Portable Agent Baseline: Git Collaboration Hygiene

- Inspect repository state before changing or committing: check the active branch and working tree when Git is available, especially before edits, staging, commits, pulls, merges, rebases, or pushes.
- Protect user and peer work: treat uncommitted or unfamiliar changes as user-owned unless proven otherwise; do not overwrite, revert, restage, or reformat unrelated work.
- Stage and commit deliberately: prefer explicit-path staging, review the staged diff before committing, and keep commit messages focused on the behavior or documentation change.
- Base new work on an up-to-date remote base: before creating a branch or opening a PR, fetch and fast-forward the base branch (e.g. `main`) to its remote tip so work starts from current state rather than a stale local ref — a local base branch can lag the remote even after its own PR has merged.
- Keep remote operations consent-based: do not push, force-push, publish branches, rewrite history, or open PRs unless the user or repo workflow has authorized it.
- Treat failures and conflicts as evidence: read CI, test, merge, and conflict output before changing code; do not blindly resolve conflicts.

This baseline takes precedence over ordinary Git habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:git-collaboration-hygiene -->

<!-- BEGIN baseline:oop-extension-safety v0.3.0 -->
## Portable Agent Baseline: OOP Extension Safety

- Complete the template method: when a base class introduces a `protected abstract` or `virtual` hook, every code path in the base class that involves that decision must route through the hook — a direct field call bypasses virtual dispatch silently.
- Prefer primitive hook parameters: abstract and virtual hook methods should accept the smallest set of primitives needed, not a whole aggregate object; aggregate parameters tie the hook to one caller shape and force bypass code paths when a second caller exists.
- Mock the most-specific injected type: test doubles should mock the exact concrete class or interface registered in DI, not a base class — mocking a base class can satisfy the injection site while hiding that the production code injects the wrong subtype.
- Declare concrete delegate types at the class level: when a class varies only in which concrete types it delegates to (not in algorithms), express that variation through type parameters or equivalent declaration-level constructs rather than constructor parameters alone — a constructor parameter silently accepts any assignable subtype, while a type parameter is visible in every diff and review.

This baseline takes precedence over ordinary implementation and test-writing habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:oop-extension-safety -->

<!-- BEGIN baseline:repo-context-grounding v0.2.0 -->
## Portable Agent Baseline: Repo Context Grounding

- Start from local instructions: read repo-level agent instructions, README, and linked docs that define setup, boundaries, ownership, or workflow.
- Inspect current state: check the active branch, working tree, and relevant recent changes before edits, pulls, commits, rebases, or pushes.
- Discover native workflows: find build, test, lint, format, run, and verification commands from repo files and docs before inventing commands.
- Respect boundaries: identify generated files, private data, external configuration, vendored code, and ownership boundaries before editing.
- Follow local patterns: match existing architecture, naming, dependency choices, test style, and documentation style before introducing new structure.
- Ask after checking available context: do not ask the user to restate repo background until local instructions and visible project context have been inspected.
- Verify at the right level: run the smallest meaningful repo-native check first, then broaden verification when changes touch shared behavior or public interfaces.

Apply this baseline as a startup habit for existing repositories, but never use
it to override explicit user instructions, safety rules, privacy boundaries, or
stricter repo-local instructions.
<!-- END baseline:repo-context-grounding -->

<!-- BEGIN baseline:commit-conventions v0.1.0 -->
## Portable Agent Baseline: Commit Conventions

- Write every commit message in the [Conventional Commits](https://www.conventionalcommits.org/) format: `<type>(<optional scope>): <description>`, optionally followed by a blank line, a body, and footer(s).
- Use one of these types: `feat` (new feature), `fix` (bug fix), `docs` (documentation only), `style` (formatting, no logic change), `refactor` (neither a fix nor a feature), `test` (adding or correcting tests), `chore` (build, tooling, or dependency updates), `ci` (CI/CD configuration).
- Keep the subject in present-tense imperative mood and 72 characters or fewer ("add logging", not "added logging"), with no trailing period. Scope is optional but encouraged in larger codebases.
- Put the "why" in the body when the change is not self-evident, wrapping prose at roughly 72 columns. Reference tracking items in the footer: `Closes #123` (GitHub) or `AB#12345` (Azure DevOps work item).
- Flag breaking changes with `!` after the type/scope (`feat(api)!: ...`) or a `BREAKING CHANGE:` footer.
- This governs message format only. It composes with `git-collaboration-hygiene` (stage explicit paths, review the staged diff before committing).

This baseline takes precedence over ordinary commit habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions (including a repository's own established commit convention).
<!-- END baseline:commit-conventions -->
