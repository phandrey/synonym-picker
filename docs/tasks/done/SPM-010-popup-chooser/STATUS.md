# SPM-010 Popup Chooser Status

## Current State
- done

## Done
- Backlog task activated.
- SPEC updated for current user request.
- Hotkey recording now suspends the previous global hotkey while recording.
- Letter hotkey labels now resolve from physical US key codes instead of active keyboard layout.
- Suggestions popup now selects the first row by default.
- Up/Down move the selected row.
- Enter confirms the selected row.
- Row click confirms that row.
- Confirmed suggestion attempts MVP replacement through clipboard paste.
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
