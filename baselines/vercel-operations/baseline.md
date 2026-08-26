# Vercel Operations Baseline

Status: active
Version: 0.4.0

This baseline installs operational habits for AI coding agents working on projects
deployed to Vercel. It directs agents to use the Vercel CLI for observability tasks
(logs, inspect, env) rather than asking the user to manually copy-paste from the
Vercel dashboard.

## Rules

1. Prefer CLI over dashboard.
   When the `vercel` CLI is available, use `vercel logs`, `vercel inspect`, and
   `vercel env ls` instead of asking the user to navigate the dashboard and
   copy-paste output.

2. Check logs before reporting errors.
   Before surfacing a Vercel function error to the user, run
   `vercel logs --output raw` to get the actual crash details. Do not describe
   an error as "unknown" without first attempting to retrieve logs.

3. Note redeployment requirements.
   After env var changes made outside the CLI, note that a manual redeploy may
   be needed for the changes to take effect in production.

4. Managed tools location.
   Vercel CLI managed by the ai-toolkit hook system lives at
   `~/.local/share/ai-toolkit/tools/node_modules/.bin/vercel`. If `vercel` is
   not in PATH, try that path directly before concluding the CLI is unavailable.

5. Changing the production branch requires the branch to exist on the remote.
   Use `PATCH /v9/projects/{id}/branch` with body `{"branch": "<name>"}` to
   change the production branch. This call fails with `git_branch_not_found`
   unless the branch already exists on the connected Git remote. The
   `PATCH /v9/projects` body does NOT accept a `link.productionBranch` property.
   (Learned 2026-07-05 in carman_church_website.)

6. Use a branch-pinned custom domain for a stable per-branch preview URL.
   A stable INT link is a branch-pinned custom domain, not an auto-generated
   alias: `POST /v10/projects/{id}/domains` with
   `{"name": "<sub>.vercel.app", "gitBranch": "<branch>"}`. Prefer this over
   the auto-generated `-git-<branch>-` aliases — those get length-truncated on
   long branch names. (Learned 2026-07-05 in carman_church_website.)

7. Preview deployments are protected by Vercel SSO by default.
   Preview deployments 302-redirect to Vercel SSO login (Deployment Protection)
   by default. Check this before sharing a preview or INT link with a client;
   disabling Deployment Protection is a security decision the user must make
   explicitly. (Learned 2026-07-05 in carman_church_website.)

8. `vercel link` may create `repo.json` instead of `project.json`.
   `vercel link --yes` may create `.vercel/repo.json` (repo-style link, project
   id under `projects[]`) instead of `.vercel/project.json`. Read both files
   when looking for the project or org id. (Learned 2026-07-05 in
   carman_church_website.)

9. Re-check GitHub App repo-access grants after a GitHub account/org rename.
   After a GitHub account/org rename, explicitly re-check and re-authorize
   connected GitHub Apps' (e.g. Vercel's) repository-access grants. OAuth-based
   auth keeps working via the internal account ID, so login and API calls may
   appear fine, but a GitHub App's stored repo-access list does not
   automatically follow the rename — deployments or repo-linked operations
   can silently fail to see the renamed repo until the grant is refreshed.

## Priority

This baseline takes precedence over ordinary implementation habits, but never use it to
override explicit user instructions, safety rules, privacy boundaries, or stricter
repo-local instructions.

## Hook companion

This baseline pairs naturally with the `ensure-vercel-cli` hook pack from
`hooks/ensure-vercel-cli/`, which auto-installs the Vercel CLI to the managed
tools directory before any Bash command runs. Install that hook via:

    hooks apply ensure-vercel-cli
