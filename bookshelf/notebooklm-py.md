---
title: notebooklm-py (teng-lin/notebooklm-py)
url: https://github.com/teng-lin/notebooklm-py
kind: tool
captured: 2026-08-26
status: unprocessed
---

Unofficial Python API, CLI, and MCP server for Google NotebookLM (rebranded
Gemini Notebook) — programmatic access to notebook management, source
ingestion, conversational querying, and generating audio overviews, videos,
slide decks, infographics, quizzes, flashcards, reports, and mind maps,
including some capabilities the web UI doesn't expose. Works from Python,
the CLI, or agents (Claude Code, Codex, OpenClaw) via its MCP server.

Install: `uv tool install "notebooklm-py[browser]"` then `notebooklm login`.

Caveat: rides undocumented Google endpoints, so it can break without notice —
best for prototypes/research, not anything load-bearing.

Surfaced in an Instagram roundup of 5 Claude Code repos. Potential fit for
research or second-brain workflows currently done by hand in the NotebookLM
web UI.
