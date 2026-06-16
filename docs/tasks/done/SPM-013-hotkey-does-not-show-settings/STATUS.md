# SPM-013 Hotkey Does Not Show Settings Status

## Current State
- done

## Done
- SPEC created.
- Root cause identified:
  - suggestions popup activates the current app with `.activateAllWindows`;
  - app launch always opens Settings even when hotkey is already configured.
- App now opens Settings on launch only when no hotkey is configured.
- Hotkey flow hides Settings before showing the suggestions popup.
- Suggestions popup activates the app without `.activateAllWindows`.
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
