# SPM-013 Hotkey Does Not Show Settings

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Pressing the configured hotkey must run the synonym lookup flow without bringing the settings window to the front.

## Scope
- Audit the hotkey activation chain.
- Prevent suggestions popup activation from showing all app windows.
- Hide the settings window before showing suggestions from a hotkey.
- Do not auto-open settings on app launch when a hotkey is already configured.
- Keep Settings available from the menu bar item.

## Out of Scope
- Real model-backed synonyms.
- Force Click trigger.
- Public packaging.
- Reworking the full permissions flow.

## Acceptance Criteria
- If a hotkey is saved, launching the app does not automatically show Settings.
- Pressing hotkey while another app is active does not bring Settings to the front.
- Suggestions popup still appears.
- Up/Down/Enter behavior from `SPM-010` still works.
- Settings can still be opened from the menu bar.

## Verify Gate
- `./scripts/verify.sh`

