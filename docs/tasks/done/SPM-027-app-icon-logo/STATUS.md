# SPM-027 App Icon Logo Status

## Current State
- done

## Done
- SPEC created.
- Source PNG inspected:
  - `1333x1180`;
  - RGBA with alpha.
- Added `Packaging/AppIconSource.png`.
- Generated `Packaging/AppIcon.icns`.
- Updated `Packaging/Info.plist` with `CFBundleIconFile = AppIcon`.
- Updated `scripts/build-app.sh` to copy `AppIcon.icns` into `Contents/Resources`.
- Confirmed built app contains `Contents/Resources/AppIcon.icns`.
- Confirmed built `Info.plist` references `AppIcon`.

## In Progress
- None.

## Next
- Reinstall app and check Finder/Dock icon.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`14/14`)
  - app bundle
