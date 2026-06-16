# SPM-026 Fast Ranked Prompt Regression Status

## Current State
- done

## Done
- SPEC created from regression report.
- Root cause identified: scored object JSON is too heavy for Qwen3 1.7B fast profile.
- Prompt now asks for an ordered JSON string array instead of scored JSON objects.
- Response `max_tokens` reduced from `360` to `190`.
- Ranked object parser compatibility remains for future use.
- Added `ё -> е` comparison normalization.
- Added test for `веселый`/`весёлый` duplicate filtering.

## In Progress
- None.

## Next
- Reinstall and smoke test `веселый`.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`14/14`)
  - app bundle
