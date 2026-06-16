# SPM-032 Parser Lexicon Quality Hardening Status

## Current State
- done

## Done
- SPEC created.
- Added comma-separated plain-text parsing for local model responses.
- Added labeled plain-text parsing for responses like `Синонимы: ...`.
- Added fast lexicon entries for `стандартный`, `локальный`, and `свежий`.
- Improved adjective lemma lookup for ambiguous hard/soft endings.
- Fixed velar-stem adjective adaptation, including `мягкий -> мягкая`.
- Added regression tests for screenshot adjective cases and plain-text parser fallbacks.
- Rebuilt `dist/SynonymPicker.app`.

## In Progress
- None.

## Next
- Manual smoke test the rebuilt app on `стандартные`, `локальные`, `свежая`, and an unknown complex word that must use the model fallback.

## Blockers
- None.

## Verify Log
- 2026-06-05: `./scripts/verify.sh` passed: lint, typecheck/build, 32 tests, app bundle.
