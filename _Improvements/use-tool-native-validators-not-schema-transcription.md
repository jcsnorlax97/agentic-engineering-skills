# When hand-crafting data for a schema-validated third-party tool, call its own validator functions instead of transcribing the schema by hand

**Captured:** 2026-09-02 — vault-for-founders / claude-obsidian ingest

## Trigger
Built a `claude-obsidian` ingest transaction bundle by hand (source and
claim ledger entries with a computed `stable_source_id`). Rather than
hand-deriving the ID from the docs' description of the hash algorithm,
imported the installed package directly (`from claude_obsidian import
ledgers`) and called `ledgers.stable_source_id(...)`,
`validate_source_ledger(...)`, `validate_claim_ledger(...)` before ever
touching the real vault. Both ledgers passed with zero errors on the
first real `transaction inspect`. A byte-exact hash field transcribed
from documentation instead would have been a real risk of a silent
mismatch.

## Rule
When a tool's write format is schema-validated by its own code (not just
documented), and that code is installed and importable/callable locally,
call its real functions to construct or verify the data rather than
reimplementing the schema from its docs — especially for any field
computed via a hash or other exact algorithm. Cheap to do, removes an
entire class of transcription error.

## Boundary
Only applies when the tool's implementation is actually available locally
(installed package, vendored script, etc.) — for a pure network API with
no local library, this doesn't apply and schema docs are the only option.

## Next step
Candidate addition to `verification-epistemics` (parallel to "don't trust
self-reported success, re-check independently" — this is the same
instinct applied to schema construction rather than state verification).
