# SPM-021 Synonym Quality Minimum Status

## Current State
- done

## Done
- SPEC created from manual screenshot feedback.
- Root issues identified:
  - provider only asks for 5-7 suggestions;
  - post-processing only removes exact duplicates/source word;
  - prompt does not strongly require grammatical form or stylistic diversity;
  - app currently sends only selected text, not surrounding sentence context.
- Provider now requests 8 candidates.
- Provider retries once when fewer than 5 usable suggestions remain.
- Prompt now asks for real Russian synonyms, same part of speech/form, and neutral/expressive/literary variety.
- Post-processing now filters invalid-looking values, selected-word variants, and obvious generated artifacts like `...образно`.
- Added backlog follow-ups:
  - `SPM-022-context-window-reader`;
  - `SPM-023-lexical-quality-engine`.

## In Progress
- None.

## Next
- Reinstall app and smoke test synonym quality.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`8/8`)
  - app bundle
