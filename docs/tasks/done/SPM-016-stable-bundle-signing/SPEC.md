# SPM-016 Stable Bundle Signing

## Status
- State: active
- Phase: M1 macOS App Foundation
- Created: 2026-06-03

## Goal
Make the local app bundle identity stable enough for macOS Accessibility/TCC to recognize the current installed app.

## Problem
`codesign -dv` shows only the executable is ad-hoc signed and the app bundle has `Info.plist=not bound` with a generated executable identifier. macOS Accessibility can show an existing checkbox while `AXIsProcessTrusted()` still returns false for the current bundle identity.

## Scope
- Sign the whole `.app` bundle during `scripts/build-app.sh`.
- Ensure the signed bundle uses `CFBundleIdentifier` (`local.synonym-picker.macos`) as the code signing identifier.
- Add a local reinstall script that resets the Accessibility TCC entry for this bundle id before reinstalling.
- Keep the existing SwiftPM verify flow.

## Out of Scope
- Developer ID signing/notarization.
- Public DMG packaging.
- Changing bundle identifier.
- Real model-backed synonyms.

## Acceptance Criteria
- `dist/SynonymPicker.app` has a bundle-level ad-hoc signature.
- `codesign -dv dist/SynonymPicker.app` reports `Identifier=local.synonym-picker.macos`.
- `Info.plist` is bound in the signature.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

