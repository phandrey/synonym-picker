# SPM-002 Menu Bar App Scaffold Status

## Status
- State: done
- Last updated: 2026-06-03

## Done
- Task moved from backlog to active.
- Scope updated for personal-install `.app` bundle and minimal translucent settings UI.
- Public GitHub release packaging deferred to `SPM-003-personal-release-packaging`.
- Executable product `SynonymPicker` added.
- Menu bar item added.
- Minimal translucent settings window added.
- Personal-install bundle script added.
- Verify gate passed.

## In Progress
- None.

## Blockers
- None currently.

## Verify Gate
- [x] lint: `swift format lint --recursive Package.swift Sources Tests`
- [x] typecheck: `swift build`
- [x] tests: `swift test`
- [x] app bundle: `./scripts/build-app.sh`

## Notes
- Full Xcode project remains out of scope for this task because `xcodebuild` is unavailable in the current environment.
