# SPM-037 Status Menu Controls Status

## Current State
- implemented and installed

## Done
- User confirmed `SPM-036` fullscreen/click-away behavior works.
- Captured requested native status menu behavior.
- Replaced visible `Settings...` status menu item with native menu rows:
  - `Hotkey: ...`;
  - `Permissions: ...`;
  - disabled `Model: Qwen3 4B`;
  - `Quit Synonym Picker`.
- Added direct hotkey recording from the status menu without opening the custom SwiftUI settings window.
- Added global key monitor support to `HotkeyRecorder` so the next shortcut can be captured after the menu closes.
- Changed Accessibility request action to open the macOS Accessibility privacy pane.
- Stopped opening the custom settings window on first launch.
- Ran `swift format`.
- Ran `./scripts/verify.sh`.
- Installed and opened `/Applications/SynonymPicker.app`.

## In Progress
- Manual menu smoke test by user.

## Next
- User checks status bar menu:
  - no `Settings...` item;
  - `Hotkey` starts shortcut recording;
  - `Permissions` opens System Settings;
  - `Model: Qwen3 4B` is visible and disabled.

## Decisions
- Keep the old SwiftUI settings window files in the project for now, but stop launching them from the normal status menu path.
- Use native `NSMenuItem` rows so the UI matches macOS system menu styling.
- Keep the disabled model row as informational only; no model switching in this pass.

## Blockers
- Installed app is still ad-hoc signed, so macOS Accessibility trust may need to be re-granted after reinstall.

## Verify Log
- `node --check scripts/benchmark-models.mjs`: passed.
- `./scripts/verify.sh`: passed; lint, build, 40 tests, app bundle.
- `./scripts/install-local.sh`: passed; `/Applications/SynonymPicker.app` installed and opened.
