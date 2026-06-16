# SPM-014 Accessibility Permission Flow Status

## Current State
- done

## Done
- SPEC created.
- Added Accessibility permission service.
- Permissions tile now shows Accessibility status.
- Permissions tile can request the macOS Accessibility prompt.
- Permission status refreshes when the app becomes active.
- Hotkey flow refreshes permission status before selection reading.
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
