

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

<!-- BEGIN baseline:code-doc-sync v0.3.0 -->
## Portable Agent Baseline: Code-Doc Sync

- Check docs before closing: when a repo has architecture docs and a task changes externally observable behavior or a contract other code depends on (a public API, a documented flow, a class relationship that appears in diagrams), check the docs that describe the changed behavior and decide explicitly whether each needs updating; skipping the check is not acceptable even for bug fixes. Purely internal changes with no observable-behavior or contract impact do not require it.
- Show the concrete runtime type: in flow diagrams and call traces involving virtual or abstract methods, use the concrete class name that executes at runtime, not the abstract declaration site — writing the base class name hides the polymorphism the diagram is meant to explain.
- Check the target repo's own decision records (ADRs, RFCs, a decision-records folder) before recommending a pattern seen working well in a sibling repo — a prior recorded decision may have deliberately picked the more manual or explicit option for a tradeoff the automatic option reintroduces. Where no decision records exist, this reduces to ordinary judgment.
- Scope each ADR to exactly one decision: write one file per genuinely independent decision, not one file per feature, PR, or component, even when several decisions touch the same component — this keeps Context/Alternatives/Consequences honest to a single choice.
- In a mixed current-state/target-design doc, tag each individual claim, arrow, or box as confirmed-in-code, designed-not-built, or unverified rather than relying on uniform notation for both, so a reader can trust what's current without redoing the investigation.

These principles are folder-name-agnostic. If the repo specifies where documentation lives (in CLAUDE.md, README, or a project-specific section), read that first. If no documentation is found, these principles fire on nothing — that is acceptable.

This baseline takes precedence over ordinary implementation habits, but never use it to override explicit user instructions, safety rules, privacy boundaries, or stricter repo-local instructions.
<!-- END baseline:code-doc-sync -->

<!-- BEGIN baseline:git-collaboration-hygiene v0.7.0 -->
## Portable Agent Baseline: Git Collaboration Hygiene

- Inspect repository state before changing or committing: check the active branch and working tree when Git is available, especially before edits, staging, commits, pulls, merges, rebases, or pushes.
- Protect user and peer work: treat uncommitted or unfamiliar changes as user-owned unless proven otherwise; do not overwrite, revert, restage, or reformat unrelated work.
- Stage and commit deliberately: prefer explicit-path staging, review the staged diff before committing, and keep commit messages focused on the behavior or documentation change.
- Keep remote operations consent-based: do not push, force-push, publish branches, rewrite history, or open PRs unless the user or repo workflow has authorized it.
- Treat failures and conflicts as evidence: read CI, test, merge, and conflict output before changing code; do not blindly resolve conflicts.
- Base new work on an up-to-date remote base: before creating a branch or opening a PR, fetch and fast-forward the base branch (e.g. `main`) to its remote tip so work starts from current state rather than a stale local ref — a local base branch can lag the remote even after its own PR has merged.
- Squash an abandoned mid-work detour before the branch's first push (`git reset --soft` + recommit) so pushed history reflects the final approach — never rewrite history that's already been pushed.
- Redo push-readiness checks (fetch, test-merge against current base, build/lint) immediately before the push itself, not earlier in the session — shared branches move.
- Before `gh pr create` or any similar authenticated write, verify the CLI's authenticated account matches the target repo's owner/org — a successful `git push` (SSH) doesn't guarantee a separately-authenticated tool targets the right account.
- Before opening a new branch/PR, check whether one already exists for the same story/ticket and extend it instead, unless the new work genuinely needs independent review. Use `git worktree` to add commits to an existing PR's branch without disturbing an unrelated in-progress checkout.
- When a merge conflict is modify/delete against an unrelated large rewrite (module migration, language port, big rename), read that rewrite's diff and new conventions before writing any port code, rather than porting the old logic in as-is.
- When a destructive command is blocked by the safety classifier, look for a non-destructive path to the same end state (e.g. `git branch -f <branch> <ref>` instead of a hard reset on a non-checked-out branch; `git rm` + `git reset --soft` instead of a hard reset when squashing).
- If the user just corrected a related action, restate a merge's direction ("merge X into Y" vs. "merge Y into X" have very different blast radii) before running the next merge-shaped command.
- Cross-diff overlapping branches against each other during review, not just each against base: when reviewing a PR while holding or knowing about a second concurrently open, unmerged branch that touches the same file, class, or config/data surface, diff the overlapping files from the two branches directly against each other — this surfaces semantic conflicts that a base-only diff never shows, since both branches can look individually clean in isolation.
- Reconstruct cross-host PR history from local clones via `git log --all --grep` on merge commits instead of paginating each host's API: when a repo is already cloned locally and the hosting platform's PR-listing API only supports listing/pagination rather than full-text search, filter merge commits by keyword instead — this works identically across GitHub, Azure DevOps, and other hosts that embed the PR title in the merge commit message, though it breaks down for squash-merge or rebase-only workflows with no distinct merge commit.
- Verify via `git log` and `git merge-base --is-ancestor` against the actual remote, not memory, whether a prior round's related work has merged before branching for follow-up work: if that related work is still unmerged (an open PR, an unreviewed branch), branch from that unmerged branch instead of the default base branch.
- Consider a long-lived, never-merged notes/diagrams branch when the team already has that convention, mirroring its existing structure rather than inventing a new one.
- Before scoping a work item that is one of several siblings under a shared parent, check every sibling's assignee and state: in any hierarchical issue tracker (Jira, Linear, GitHub Projects, Azure DevOps, etc.), query the parent's other child items before committing to a scope, and narrow your own scope rather than duplicating overlapping work a sibling is already actively covering.
- Reference a work item's own ID in commit messages and branch names, not its parent's: in a hierarchical tracker, referencing the wrong level causes the tracker's auto-link to attach the change to the parent instead of the child, making the real item look untouched in status reports and dashboards.
- Before pushing additional commits to an already-open PR branch, verify the PR is still open: a reviewer can merge it while you're still working, and pushing to a since-merged branch just strands the commits outside `main` rather than failing loudly — if it's merged, branch fresh from an updated `main`, cherry-pick the stranded commits, and open a new PR instead of force-pushing into a closed one.

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

<!-- BEGIN baseline:repo-context-grounding v0.3.2 -->
## Portable Agent Baseline: Repo Context Grounding

- Start from local instructions: read repo-level agent instructions, README, and linked docs that define setup, boundaries, ownership, or workflow.
- Inspect current state: check the active branch, working tree, and relevant recent changes before edits, pulls, commits, rebases, or pushes.
- Discover native workflows: find build, test, lint, format, run, and verification commands from repo files and docs before inventing commands.
- Respect boundaries: identify generated files, private data, external configuration, vendored code, and ownership boundaries before editing.
- Follow local patterns: match existing architecture, naming, dependency choices, test style, and documentation style before introducing new structure.
- Ask after checking available context: do not ask the user to restate repo background until local instructions and visible project context have been inspected.
- Verify at the right level: run the smallest meaningful repo-native check first, then broaden verification when changes touch shared behavior or public interfaces.
- Before proposing new process, tooling, or a new skill/repo/governance layer, check whether the repo already documents a build-gate or promotion doctrine (e.g. a "pain twice, dated" rule) and evaluate against it, rather than relying on vague recollection.
- Check for a local copy before asking to re-supply: when a chat or integration tool can only describe an attachment (filename, size, metadata) but cannot fetch or render its content, check whether the same file already exists on local disk before asking the user to re-supply it.
- Prefer an installed shim/wrapper command over a repo's raw tooling script path: check `Get-Command <name>` / `where <name>` for an installed CLI before falling back to a raw script path. A repo may deliberately name its shim differently from its own script path (e.g. a prefix distinguishing it from a sibling repo's identically-structured tool) so invocations don't cross-target the wrong repo — and any command text written into commit messages or PR descriptions inherits the same wrong name if you skip this check.

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
