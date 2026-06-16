# SPM-025 Contextual Ranking Leaderboard Status

## Current State
- done

## Done
- SPEC created from manual smoke-test feedback.
- Added `RankedSynonymCandidate` in core.
- Added ranked post-processing that sorts by contextual score and keeps the highest scored duplicate.
- Provider now asks the model for JSON objects with `word` and `score`.
- Provider still parses legacy string-array JSON.
- Popup order now follows local score sorting after filtering.
- Kept current speed contract: no mandatory extra model request.

## In Progress
- None.

## Next
- Reinstall and smoke test generic adjectives in context.
- If ranking is still weak, activate `SPM-023-lexical-quality-engine`.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`13/13`)
  - app bundle
