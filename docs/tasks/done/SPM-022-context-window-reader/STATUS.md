# SPM-022 Context Window Reader Status

## Current State
- done

## Done
- SPEC moved from backlog to active after smoke-test showed semantic drift (`срал` -> `сжал`).
- Root cause identified: current provider receives only selected text, so the small local model has no sentence context for sense disambiguation.
- Added `TextContextExtractor` in core.
- Added Accessibility context reader for focused text fields.
- Selection reader now captures context before clipboard copy fallback.
- Local provider now receives optional context.
- Prompt now explicitly uses context for sense disambiguation.
- Prompt now says not to typo-correct the selected word to a visually similar word.
- Prompt now preserves obscene/colloquial meaning instead of sanitizing it.
- Added unit tests for context extraction.

## In Progress
- None.

## Next
- Reinstall app and smoke test with vulgar/colloquial verbs and ambiguous adjectives.
- If quality is still weak, activate `SPM-023-lexical-quality-engine`.

## Blockers
- Some source apps may not expose full focused text through Accessibility; clipboard-only fallback must remain.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`11/11`)
  - app bundle
