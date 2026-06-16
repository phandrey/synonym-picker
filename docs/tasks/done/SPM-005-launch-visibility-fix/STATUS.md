# SPM-005 Launch Visibility Fix Status

## Status
- State: done
- Last updated: 2026-06-03

## Done
- Task activated.
- Settings window opens automatically on launch.
- Menu bar item shows visible `Syn` text.
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
