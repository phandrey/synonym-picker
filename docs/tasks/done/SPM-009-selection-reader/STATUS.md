# SPM-009 Selection Reader Status

## Current State
- done

## Done
- SPEC created.
- Added clipboard-preserving selection reader.
- Wired selection reader into global hotkey handling.
- Updated mock suggestions popup to show captured text or fallback state.
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
- 2026-06-03: final `./scripts/verify.sh` passed after task board updates.
