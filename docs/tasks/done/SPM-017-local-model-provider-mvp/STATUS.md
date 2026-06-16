# SPM-017 Local Model Provider MVP Status

## Current State
- done

## Done
- SPEC created.
- Added model catalog with fast and quality model metadata.
- Default fast profile is `Qwen3 1.7B Q4_K_M`.
- Added local OpenAI-compatible synonym provider for `llama-server`.
- AI provider output is parsed and post-processed before display.
- Popup now uses provider suggestions when available.
- Popup shows a clear model-not-ready fallback when the local provider is unavailable.
- Settings model tile now reflects the external fast model state.
- Added `docs/MODELS.md`.
- Verify gate passed.

## In Progress
- None.

## Next
- None.

## Blockers
- None.

## Verify Log
- 2026-06-03: `./scripts/verify.sh` passed:
  - lint ok
  - typecheck/build ok
  - tests ok (6 tests)
  - app bundle ok
