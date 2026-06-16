# SPM-037 Status Menu Controls

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-09

## Goal
Replace the status bar `Settings...` launcher with native macOS menu items for hotkey setup, permissions, model display, and quit.

## Scope
- Remove the visible `Settings...` menu action from the status bar menu.
- Add a `Hotkey` menu item that starts hotkey recording directly from the native menu.
- Add a `Permissions` menu item that requests Accessibility permission / opens the system permission flow.
- Add a disabled model information row showing the active default model.
- Keep `Quit Synonym Picker`.
- Preserve existing hotkey registration, replacement flow, model runtime, and Accessibility behavior.

## Out of Scope
- Rebuilding the old custom SwiftUI settings screen.
- Adding model switching UI.
- Stable Developer ID signing.

## Acceptance Criteria
- Status bar menu contains native items for hotkey, permissions, model, and quit.
- Choosing `Hotkey` records a new shortcut without opening the custom settings window.
- Choosing `Permissions` triggers the same Accessibility request path.
- The model row is visible and disabled.
- `./scripts/verify.sh` passes.
- `/Applications/SynonymPicker.app` is reinstalled.
