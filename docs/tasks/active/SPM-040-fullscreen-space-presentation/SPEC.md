# SPM-040 Fullscreen Space Presentation

## Status
- State: active
- Phase: Fullscreen overlay hardening
- Created: 2026-06-16

## Goal
Make the suggestions popup appear in the source application's fullscreen Space more reliably without changing normal app behavior.

## Problem
Manual testing showed the popup can appear on the desktop layer while the intended source app is in macOS fullscreen. The existing panel already has high window level and fullscreen collection behavior, so the remaining failure mode is primarily Space timing: the panel can be ordered while Mission Control, Dock, or SynonymPicker has focus instead of the source app's fullscreen Space.

## Scope
- Keep the non-activating `NSPanel` behavior.
- Keep `.screenSaver`, `.canJoinAllSpaces`, `.canJoinAllApplications`, and `.fullScreenAuxiliary`.
- Restore focus to the source app only when focus was taken by SynonymPicker or Dock/Mission Control.
- Delay popup presentation briefly after restoring the source app so macOS can switch Spaces first.
- Retry briefly if Mission Control is still active, then avoid showing the popup on the wrong layer.

## Out of Scope
- Drawing above Mission Control thumbnails.
- Notarization or signing changes.
- Changing model, menu, install, or replacement behavior.

## Acceptance Criteria
- Normal popup display still compiles and passes the standard verification gate.
- Popup presentation no longer attempts to display over Dock/Mission Control as the source.
- Popup avoids stealing the user back from another regular app if they switched away while suggestions were loading.
- `./scripts/verify.sh` passes.

## Verify Gate
- `swift build`
- `./scripts/verify.sh`
