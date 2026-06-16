# SPM-011 Popup Dismiss and Status Icon Status

## Current State
- done

## Done
- SPEC created.
- Popup now dismisses automatically after a short delay.
- Popup dismisses on click.
- Popup dismisses on Escape when the app receives the key event.
- Status bar item now uses a compact square icon slot with a fallback text label.
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
