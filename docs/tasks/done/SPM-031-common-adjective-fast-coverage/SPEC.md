# SPM-031 Common Adjective Fast Coverage

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-05

## Goal
Reduce `No usable synonyms` for common Russian adjectives by expanding the fast local lexical layer.

## Problem
Smoke tests show `сложные` can fall through to the local model and then be filtered down to no usable suggestions. This is a common adjective case that should not depend on Qwen generation quality.

## Scope
- Add fast local seed entries for common adjectives that frequently appear in user text.
- Cover `сложный -> сложные` specifically.
- Keep model fallback unchanged for unknown words.
- Keep output speed fast for covered words.
- Add unit tests for new coverage.

## Out of Scope
- Full thesaurus import.
- Model replacement.
- Popup redesign.
- Public packaging.

## Acceptance Criteria
- `сложные` returns at least five usable plural adjective replacements from the fast layer.
- Common adjective entries preserve form via existing post-processing.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
