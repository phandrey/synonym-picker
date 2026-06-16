# SPM-010 Popup Chooser

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Make the suggestions popup selectable and make the hotkey flow usable with Russian keyboard layout enabled.

## Scope
- Fix hotkey recording so the previously registered global hotkey does not fire while choosing a new shortcut.
- Resolve recorded hotkey labels from physical US key codes instead of the currently active keyboard layout.
- Track a selected suggestion in the popup UI.
- Support Up/Down navigation.
- Support Enter selection.
- Support mouse click selection.
- Insert the selected mocked synonym into the source app through an MVP clipboard paste fallback.

## Out of Scope
- Real model-backed suggestions.
- Model download UI.
- Full context extraction beyond the selected text.
- Force Click / deep trackpad press trigger. This is tracked separately in `SPM-012-force-click-trigger`.

## Acceptance Criteria
- Popup shows a visible selected row.
- The first suggestion is selected when the popup opens.
- Down/Up changes the selected row.
- Enter confirms and attempts to insert the selected row.
- Clicking a row confirms and attempts to insert that row.
- Recorded letter hotkeys display as US/English physical key names even when Russian layout is active.
- Re-recording a hotkey does not leave the UI stuck in `Recording` because the previous global hotkey fired.
- Existing hotkey and selection-reader behavior still works.

## Verify Gate
- `./scripts/verify.sh`
