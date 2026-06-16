# SPM-033 Model First Synonym Generation Status

## Current State
- done

## Done
- Removed fast lexical lookup from `LocalSynonymProvider`.
- Deleted `FastSynonymLexicon` from core sources.
- Deleted fast lexicon tests that encoded the previous shortcut behavior.
- Removed retry request logic from model generation.
- Set model generation to a single request with a 2.8 second timeout.
- Reduced hotkey model-runtime wait to 2.5 seconds.
- Kept parser fallbacks for JSON, embedded JSON, comma-separated text, and labeled text.
- Added morphology regression tests for model-returned velar adjective bases.
- Rebuilt `dist/SynonymPicker.app`.

## In Progress
- None.

## Next
- Manual smoke test with the rebuilt app while `llama-server` is warm:
  - `хорошо`
  - `стандартные`
  - `локальные`
  - `свежая выпечка`
  - one intentionally harder contextual word

## Blockers
- Live CLI smoke test could not be completed because port `8080` appeared occupied by a `llama-server` listener while `/v1/models` refused connections. I did not kill that process.

## Verify Log
- 2026-06-05: `./scripts/verify.sh` passed: lint, typecheck/build, 28 tests, app bundle.
