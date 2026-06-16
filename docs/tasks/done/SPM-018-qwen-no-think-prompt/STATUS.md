# SPM-018 Qwen No-Think Prompt Status

## Current State
- done

## Done
- SPEC created.
- Manual server test confirmed `/no_think` returns JSON in `content`.
- Provider prompt now includes `/no_think`.
- Provider max output budget increased to 120 tokens.
- Model docs include the no-think note.
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
