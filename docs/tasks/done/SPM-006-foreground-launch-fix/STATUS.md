# SPM-006 Foreground Launch Fix Status

## Status
- State: done
- Last updated: 2026-06-03

## Done
- Task activated.
- `LSUIElement` removed from `Info.plist`.
- Activation policy switched to `.regular`.
- Settings window is explicitly ordered front.
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
