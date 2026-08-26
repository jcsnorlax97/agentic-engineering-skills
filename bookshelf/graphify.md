---
title: graphify (Graphify-Labs/graphify)
url: https://github.com/Graphify-Labs/graphify
kind: skill-repo
captured: 2026-08-26
status: unprocessed
---

`/graphify` skill for Claude Code, Cursor, Codex, Gemini CLI, and other AI
coding assistants — turns a folder of code, docs, SQL schemas, PDFs, images,
or video/audio into a queryable knowledge graph using local deterministic
AST parsing (tree-sitter, 37+ languages), no vector store. Outputs an
interactive `graph.html`, a `GRAPH_REPORT.md`, and a queryable `graph.json`,
tagging each relationship as EXTRACTED (explicit) or INFERRED.

Install: `uv tool install graphifyy` then `graphify install`.

Caveat: several same-named forks/orgs exist (`sharkkyyy10/graphify-`,
`safishamsi/graphify`), and the star counts shown on fetched pages
(100k+) look implausible for repos this size — unverified, don't trust
at face value until checked directly on github.com before relying on it.

Surfaced in an Instagram roundup of 5 Claude Code repos. Interesting as a
"map the codebase before touching it" step on an unfamiliar repo.
