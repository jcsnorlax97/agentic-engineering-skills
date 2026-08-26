---
title: claude-video (bradautomates/claude-video)
url: https://github.com/bradautomates/claude-video
kind: skill-repo
captured: 2026-08-26
status: unprocessed
---

Claude Code skill (`/watch` command) that gives Claude the ability to watch
any video: downloads it (`yt-dlp`), extracts frames (`ffmpeg`), transcribes
audio (free captions, or Whisper API fallback), and hands the whole thing to
Claude for analysis. Use cases shown: diagnosing bugs from screen recordings,
summarizing videos, extracting info from presentations, content-strategy
review.

Install: `/plugin marketplace add bradautomates/claude-video` then
`/plugin install watch@claude-video`.

Surfaced in an Instagram roundup of 5 Claude Code repos. Worth trying next
time a bug report or review needs frame-level video analysis instead of
manually screenshotting.
