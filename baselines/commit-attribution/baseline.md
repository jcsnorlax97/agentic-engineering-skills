# Commit Attribution Baseline

Status: active
Version: 0.1.0

This is a tool-neutral always-on baseline for AI coding agents that write
commits in this team's repositories. It sets how AI assistance is attributed in
commit history: keep the trailer block clean and, if attribution is worth
noting at all, say so in a short prose line instead.

## Principles

1. No AI co-author trailers.
   Do not add `Co-Authored-By: Claude ...`, any other `Co-Authored-By:` line
   naming an AI, or equivalent co-author metadata to commit messages.

2. No "generated with" footers.
   Do not append "Generated with Claude Code", "Made with <AI>", tool
   advertising, or similar footer lines to commits.

3. Mention assistance in prose, briefly, if at all.
   When it is useful to record that a change was produced with AI assistance,
   add at most one short line in the commit body (e.g. "Assisted by Claude.")
   rather than a structured co-author trailer.

4. Keep the change the headline.
   The commit subject and body describe the behavior or documentation change.
   Attribution is never the subject line and never more than a brief note.

## Priority

Apply this baseline before ordinary commit habits, but never use it to override
explicit user instructions, safety rules, privacy boundaries, or stricter
repo-local instructions. If the user or a repo convention explicitly asks for a
co-author trailer, follow that instead.

## Non-Goals

- This does not relax commit hygiene: still write descriptive messages, stage
  explicit paths, and review the staged diff before committing.
- This does not govern PR descriptions, changelogs, or release notes.
- This does not forbid required legal or Signed-off-by trailers where a repo
  mandates them.
