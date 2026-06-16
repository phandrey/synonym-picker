# SPM-034 Verb Quality Telegram Overlay

## Status
- State: done
- Phase: M3 Local Model
- Created: 2026-06-07

## Goal
Fix model-only synonym quality for finite Russian verbs and make the popup reliably appear over Telegram and other foreground apps.

## Problem
Manual screenshots showed:
- `попробуем` produced `No usable synonyms`;
- `переделывал` produced same-lexeme forms such as `переделывать` and `переделать`;
- the suggestions popup did not reliably appear above Telegram/other apps.

## Scope
- Raise the suggestions panel above normal app windows and fullscreen auxiliary windows.
- Keep the popup visible even if the app deactivates.
- Place the popup on the screen containing the mouse pointer.
- Tighten the model prompt for finite Russian verbs.
- Let the model return 4-8 good candidates instead of forcing exactly 8.
- Add post-processing guards for finite verb shape and same-lexeme verb variants.
- Add regression tests for `попробуем` and `переделывал`.
- Rebuild and install the app.

## Out of Scope
- Full Russian morphology engine.
- Public signing/notarization.
- Killing existing external `llama-server` processes.

## Acceptance Criteria
- Popup window uses an always-on-top overlay level.
- `попробовать` is filtered out for source `попробуем`.
- `попытаемся`, `проверим`, and `протестируем` pass for source `попробуем`.
- `переделывать` and `переделать` are filtered out for source `переделывал`.
- `исправлял` and `дорабатывал` pass for source `переделывал`.
- Verify gate passes.
- `/Applications/SynonymPicker.app` is replaced with the rebuilt app.

## Verify Gate
- `./scripts/verify.sh`
- `./scripts/install-local.sh`
