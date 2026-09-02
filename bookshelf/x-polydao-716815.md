---
title: Claude + Obsidian + Loop Engineering: a vault that runs itself (@polydao)
url: https://x.com/polydao/status/2094307289280716815
kind: article
captured: 2026-09-01
status: unprocessed
---

Architecture for a self-running Obsidian vault where the vault IS the agent loop's state, not the chat window. Loop: capture (00-inbox) -> context (Claude pulls links/tags/neighbor notes) -> draft (git worktree, never the live vault) -> review (critic agent checks diff) -> commit (append-only). Frontmatter fields (supports/contradicts/supersedes) act as graph edges. Recommends starting with a plain loop (~2-4x cost of one direct call) and only moving to a full graph once state must outlive a session, multiple agents coordinate, or you need to explain what changed (10-50x cost). Claims one review assistant went 55%->72%->84% accuracy moving through these shapes in order. Directly relevant: the review-gate step before writing to live notes. Fetched via fxtwitter mirror.
