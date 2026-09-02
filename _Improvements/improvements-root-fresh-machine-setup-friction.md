# improvement-extraction has no fresh-machine setup guidance for IMPROVEMENTS_ROOT

**Captured:** 2026-09-02 — vault-for-founders session, first run on this machine

## Trigger
Ran `/improvement-extraction` on a machine where `IMPROVEMENTS_ROOT` had
never been set and `ai-toolkit/_Improvements/` didn't exist yet. The skill
correctly stopped and asked, but the user didn't know what path to use —
had to be told the convention exists on their other machine (learned only
from `vault-changelog.md` history, not from the skill itself) before a
sensible default could be suggested. The skill's own Step 1 says "ask the
user for the path once" but gives no guidance on *what* to suggest.

## Rule
`improvement-extraction`'s Step 1 should suggest a concrete default (e.g.
`<nearest ai-toolkit checkout>/_Improvements/`) when asking for the path,
rather than an open-ended "what path do you want" — most users won't have
a considered answer ready on a fresh machine.

## Next step
Add one line to Step 1: if a local `ai-toolkit` checkout is discoverable
near the current working directory, propose `_Improvements/` under it as
the default; otherwise ask open-ended as today.
