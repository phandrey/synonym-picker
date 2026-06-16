# SPM-040 Fullscreen Space Presentation Status

## Current State
- implemented and verified

## Done
- Captured the fullscreen Space regression from user screenshot and discussion.
- Identified that the old fix already used high window level and fullscreen collection behavior.
- Added delayed popup presentation after restoring the source application's Space.
- Added Mission Control/Dock guards so the popup is not shown on the wrong desktop layer.
- Kept focus restoration narrow: only SynonymPicker or Dock/Mission Control can trigger a return to the source app.
- Reapplied overlay collection behavior at presentation time.
- Ran `swift build`: passed.
- Ran `./scripts/verify.sh`: passed.

## In Progress
- None.

## Next
- Commit and push the fix to GitHub.

## Decisions
- Do not use deprecated `.activateIgnoringOtherApps`; ordinary source-app activation is enough on the supported macOS baseline.
- Do not try to draw over Mission Control thumbnails because macOS does not allow reliable third-party overlay behavior there.
- Avoid stealing focus from another regular application if the user switches away while model suggestions are loading.

## Blockers
- None.

## Verify Log
- `swift build`: passed on 2026-06-16.
- `./scripts/verify.sh`: passed on 2026-06-16; lint, typecheck/build, 45 tests, and app bundle.
