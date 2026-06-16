# SPM-015 Robust Selection Reader Status

## Current State
- done

## Done
- SPEC created.
- Root cause candidate identified: fixed 180 ms copy delay can read before the foreground app updates pasteboard.
- Replaced fixed-delay selection reading with pasteboard change-count polling.
- Increased bounded wait to 1.2 seconds.
- Fallback popup now shows the actual failure message instead of always blaming Accessibility.
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
