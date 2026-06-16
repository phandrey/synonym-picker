# SPM-009 Selection Reader

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
When the registered global hotkey is pressed, the app attempts to read the currently selected text from the foreground app and shows that captured text in the existing mock suggestions popup.

## Scope
- Add a local selected-text reader for macOS using a clipboard copy fallback.
- Preserve and restore the user's existing clipboard after the read attempt.
- Wire the reader into the global hotkey flow.
- Update the mock suggestions popup so it can display:
  - the selected text when reading succeeds;
  - a short no-selection/permission message when reading fails.
- Keep suggestions mocked.

## Out of Scope
- Real synonym generation.
- Model download or inference.
- Replacing text in the source app.
- Keyboard navigation inside the suggestions popup.
- Full accessibility-permission onboarding UI.

## Acceptance Criteria
- Pressing the configured hotkey attempts to copy the current selection from the frontmost app.
- Existing clipboard content is restored after the read attempt.
- Popup still opens after hotkey press.
- Popup shows the selected word/text when available.
- Popup shows a clear fallback state when no text was captured.
- Existing settings UI and hotkey configuration still work.

## Implementation Notes
- Use AppKit/CoreGraphics APIs available in the current SwiftPM setup.
- Use `CGEvent` to send Command+C.
- Keep the read delay short and explicit.
- Avoid adding third-party dependencies.

## Verify Gate
- `./scripts/verify.sh`

