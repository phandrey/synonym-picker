# SPM-016 Stable Bundle Signing Status

## Current State
- done

## Done
- SPEC created.
- Root cause identified: bundle is not signed as a stable app identity.
- `scripts/build-app.sh` now signs the full `.app` bundle ad-hoc.
- `codesign -dv dist/SynonymPicker.app` now reports `Identifier=local.synonym-picker.macos`.
- `Info.plist` is included in the bundle signature.
- Added `scripts/install-local.sh` for local reinstall plus Accessibility TCC reset.
- Verify gate passed.

## In Progress
- None.

## Next
- None.

## Blockers
- None.

## Verify Log
- 2026-06-03: `./scripts/verify.sh` passed:
  - lint ok
  - typecheck/build ok
  - tests ok (6 tests)
  - app bundle ok
- 2026-06-03: `codesign -dv --verbose=4 dist/SynonymPicker.app` reports `Identifier=local.synonym-picker.macos` and `Info.plist entries=10`.
