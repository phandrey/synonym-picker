# SPM-011 Popup Dismiss and Status Icon

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Fix the current MVP ergonomics: the suggestions popup should not stay on screen indefinitely, and the running app should expose a visible menu bar item.

## Scope
- Make the suggestions popup dismiss automatically after a short delay.
- Add explicit popup dismissal on click and Escape where AppKit receives the event.
- Configure the status bar item as a compact visible icon with a fallback label.
- Keep the settings UI, hotkey registration, selection reader, and mocked suggestions behavior intact.

## Out of Scope
- Real text replacement.
- Full popup chooser/navigation.
- Model download or inference.
- macOS permission onboarding.

## Acceptance Criteria
- Suggestions popup no longer remains on screen indefinitely.
- Clicking the popup dismisses it.
- Pressing Escape dismisses it when the app receives the key event.
- Menu bar item uses a compact fixed slot and remains retained for the app lifetime.
- Existing hotkey flow still opens the popup.

## Verify Gate
- `./scripts/verify.sh`

