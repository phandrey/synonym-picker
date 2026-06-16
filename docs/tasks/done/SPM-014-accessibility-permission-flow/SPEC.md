# SPM-014 Accessibility Permission Flow

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Make the app explicitly request and display macOS Accessibility permission, because selection reading and replacement depend on synthetic keyboard events.

## Scope
- Add an Accessibility permission service.
- Make the Permissions tile interactive.
- Show current permission status in the settings UI.
- Request the system Accessibility prompt from the app.
- Re-check permission status when the app becomes active.
- Update the hotkey flow so it records permission status before trying to read selected text.

## Out of Scope
- Full permissions onboarding screen.
- Real model-backed synonyms.
- Force Click trigger.
- Replacing the clipboard-based selection reader.

## Acceptance Criteria
- Permissions tile can trigger the macOS Accessibility permission prompt.
- Permissions tile displays whether Accessibility is granted.
- If permission is missing, the user can see why selection reading may fail.
- Existing hotkey, popup, keyboard navigation, and mock replacement still build and test.

## Verify Gate
- `./scripts/verify.sh`

