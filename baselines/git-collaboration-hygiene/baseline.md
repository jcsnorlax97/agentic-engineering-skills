# Git Collaboration Hygiene Baseline

Status: active
Version: 0.6.0

This is a tool-neutral always-on baseline for AI coding agents working in Git
repositories. It captures collaboration safety that should apply before
workflow-specific PR, release, deploy, or multi-agent procedures.

## Principles

1. Inspect repository state before changing or committing.
   Check the active branch and working tree when Git is available, especially
   before edits, staging, commits, pulls, merges, rebases, or pushes.

2. Protect user and peer work.
   Treat uncommitted or unfamiliar changes as user-owned unless proven
   otherwise. Do not overwrite, revert, restage, or reformat unrelated work.
   If a touched file has changed, read it and integrate with the current state.

3. Stage and commit deliberately.
   Prefer explicit-path staging. Review the staged diff before committing.
   Keep commits scoped to the behavior or documentation change, and use commit
   messages that describe the change rather than the tool.

4. Keep remote operations consent-based.
   Do not push, force-push, publish branches, rewrite history, or open PRs
   unless the user or repo workflow has authorized it. Pull or integrate remote
   changes only when the working tree and branch strategy make that safe.

5. Treat failures and conflicts as evidence.
   Read CI, test, merge, and conflict output before changing code. Do not
   blindly resolve conflicts or mark generated output as fixed without a
   concrete verification step.

6. Base new work on an up-to-date remote base.
   Before creating a branch or opening a PR, fetch and fast-forward the base
   branch (e.g. `main`) to its remote tip so new work starts from current state
   rather than a stale local ref. A local base branch can lag the remote even
   after its own PR has merged; sync it before branching instead of assuming it
   is current.

7. Squash an abandoned mid-work detour before the first push.
   If the implementation approach changed mid-session — an abandoned design
   was tried, then replaced — squash the abandoned attempt out of history
   (`git reset --soft` + recommit) before the branch's first push, so the
   pushed history reflects the final approach. Never do this once anything on
   the branch has already been pushed; rewrite only unpushed local history.

8. Redo push-readiness checks immediately before pushing, not earlier.
   Re-run fetch, a test-merge against the current base, and build/lint
   immediately before the push itself rather than trusting a check done
   earlier in the session — shared branches move, and an earlier "looks
   ready" can go stale by the time you actually push.

9. Verify the authenticated identity before a hosted-platform write.
   Before `gh pr create` (or any similar authenticated write operation),
   verify the CLI's authenticated account matches the target repo's
   owner/org. A successful `git push` (SSH-authenticated) does not guarantee
   a separately-authenticated tool's session will target the right account.

10. Reuse an existing open PR for the same story instead of opening a new
    one.
    Before opening a new branch/PR, check whether one already exists for the
    same story/ticket — extend it rather than forking a new one, unless the
    new work genuinely needs independent review. Use `git worktree` to add
    commits to an existing PR's branch without disturbing an unrelated
    in-progress checkout on the same branch.

11. When a merge conflict is modify/delete against an unrelated large
    rewrite, read the new structure first.
    If the conflict is modify/delete and the deleting side is an unrelated
    large rewrite (module migration, language port, big rename), read that
    rewrite's diff and new conventions before writing any port code — treat
    the rewrite as the spec for "how things are organized now" rather than
    porting the old logic in as-is.

12. When a destructive command is blocked by the safety classifier, look for
    a non-destructive path to the same end state.
    A blocked `git reset --hard` on a shared branch can often be replaced by
    moving a non-checked-out branch's pointer directly (`git branch -f
    <branch> <ref>`); a blocked hard reset when squashing commits can often
    be replaced by `git rm` + `git reset --soft` (index/HEAD only, working
    tree untouched). Prefer finding the non-destructive equivalent over
    trying to force the original command through.

13. Restate a merge's direction explicitly if a related action just drew a
    correction.
    "Merge X into Y" and "merge Y into X" have very different blast radii,
    and shorthand descriptions of the two look alike. If the user has just
    corrected a related action (e.g. an unnecessary new branch), don't assume
    the next merge-shaped command's direction is obviously understood —
    restate which way it goes before running it.

14. Cross-diff overlapping branches against each other during review, not
    just each against base.
    When reviewing a PR while holding or knowing about a second concurrently
    open, unmerged branch that touches the same file, class, or config/data
    surface, diff the overlapping files from the two branches directly
    against each other, not just each against the shared base — this
    surfaces semantic conflicts that a base-only diff never shows, since both
    branches can look individually clean in isolation.

15. Reconstruct cross-host PR history from local clones via `git log --all
    --grep` on merge commits instead of paginating each host's API.
    When a repo is already cloned locally and the hosting platform's
    PR-listing API only supports listing/pagination rather than full-text
    search, filter merge commits by keyword instead — this works identically
    across GitHub, Azure DevOps, and other hosts that embed the PR title in
    the merge commit message, though it breaks down for squash-merge or
    rebase-only workflows with no distinct merge commit.

16. Verify via `git log` and `git merge-base --is-ancestor` against the
    actual remote, not memory, whether a prior round's related work has
    merged before branching for follow-up work.
    If that related work is still unmerged (an open PR, an unreviewed
    branch), branch from that unmerged branch instead of the default base
    branch.

17. Consider a long-lived, never-merged notes/diagrams branch when the team
    already has that convention, mirroring its existing structure rather
    than inventing a new one.

18. Before scoping a work item that is one of several siblings under a
    shared parent, check every sibling's assignee and state.
    In any hierarchical issue tracker (Jira, Linear, GitHub Projects, Azure
    DevOps, etc.), query the parent's other child items before committing to
    a scope. If a sibling is already actively covering overlapping work,
    narrow your own scope rather than duplicating it — even if that means
    shipping less than the full item.

19. Reference a work item's own ID in commit messages and branch names, not
    its parent's.
    In a hierarchical tracker, a commit or branch reference should point to
    the specific item you are actually working (the story, task, or bug),
    not the parent epic or feature. Referencing the wrong level causes the
    tracker's auto-link to attach the change to the parent instead of the
    child, making the real item look untouched in status reports and
    dashboards.

## Priority

This baseline takes precedence over ordinary Git habits, but never use it to override
explicit user instructions, safety rules, privacy boundaries, or stricter
repo-local instructions.

## Non-Goals

- This is not a PR creation workflow.
- This is not a release or deploy procedure.
- This does not require every small answer to run Git commands.
- This does not permit broad staging, force pushes, secret commits, or private
  runtime artifact commits.
