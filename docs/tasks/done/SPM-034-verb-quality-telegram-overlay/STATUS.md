# SPM-034 Verb Quality Telegram Overlay Status

## Current State
- done

## Done
- Suggestions popup level raised to `.screenSaver`.
- Popup no longer hides automatically when SynonymPicker deactivates.
- Popup now chooses the screen containing the mouse pointer.
- Prompt now requires finite verb form preservation.
- Prompt now rejects infinitives for finite verb sources.
- Prompt now asks for 4-8 good candidates instead of exactly 8.
- Post-processor now rejects same-lexeme verb variants.
- Post-processor now checks broad finite verb shape compatibility.
- Added regression tests for `попробуем` and `переделывал`.
- Rebuilt and installed `/Applications/SynonymPicker.app`.

## In Progress
- None.

## Next
- Manual smoke test in Telegram:
  - `попробуем`
  - `переделывал`
  - popup visibility over Telegram

## Blockers
- None.

## Verify Log
- 2026-06-07: `./scripts/verify.sh` passed: lint, typecheck/build, 30 tests, app bundle.
- 2026-06-07: `./scripts/install-local.sh` passed and installed `/Applications/SynonymPicker.app`.
