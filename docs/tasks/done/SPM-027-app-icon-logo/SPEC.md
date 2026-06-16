# SPM-027 App Icon Logo

## Status
- State: active
- Phase: M1 macOS App Foundation
- Created: 2026-06-04

## Goal
Use the provided logo PNG as the application icon for the macOS app bundle.

## Scope
- Add the provided logo asset to the project packaging resources.
- Generate a macOS `.icns` app icon.
- Copy the icon into `Contents/Resources` during bundle build.
- Set `CFBundleIconFile` in `Info.plist`.
- Verify the app bundle builds successfully.

## Out of Scope
- Redesigning the logo.
- Changing in-app UI branding.
- Public notarized release packaging.

## Acceptance Criteria
- `dist/SynonymPicker.app/Contents/Resources/AppIcon.icns` exists after build.
- `Info.plist` references `AppIcon`.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
