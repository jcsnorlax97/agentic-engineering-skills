# Repo Context Grounding

Status: active
Version: 0.3.1

Before meaningful work in an existing repository:

- Start from local instructions: read repo-level agent instructions, README, and linked docs that define setup, boundaries, ownership, or workflow.
- Inspect current state: check the active branch, working tree, and relevant recent changes before edits, pulls, commits, rebases, or pushes.
- Discover native workflows: find build, test, lint, format, run, and verification commands from repo files and docs before inventing commands.
- Respect boundaries: identify generated files, private data, external configuration, vendored code, and ownership boundaries before editing.
- Follow local patterns: match existing architecture, naming, dependency choices, test style, and documentation style before introducing new structure.
- Ask after checking available context: do not ask the user to restate repo background until local instructions and visible project context have been inspected.
- Verify at the right level: run the smallest meaningful repo-native check first, then broaden verification when changes touch shared behavior or public interfaces.
- Before proposing new process, tooling, or a new skill/repo/governance layer in a repo, explicitly check whether that repo already documents a build-gate or promotion doctrine (e.g. a "pain twice, dated" rule) and evaluate the proposal against it — rather than relying on vague recollection of whether such a doctrine exists.
- Check for a local copy before asking to re-supply: when a chat or integration tool can only describe an attachment (filename, size, metadata) but cannot fetch or render its content, check whether the same file already exists on local disk before asking the user to re-supply it.

## Priority

This baseline is a startup and context-grounding habit. It does not replace
repo-specific instructions, project-specific setup docs, or triggered workflow
skills, and it never overrides explicit user instructions, safety rules, or
privacy boundaries.
