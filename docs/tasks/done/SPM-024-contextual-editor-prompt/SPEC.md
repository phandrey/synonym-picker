# SPM-024 Contextual Editor Prompt

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Improve synonym relevance from the current fast local model without adding another model call or new dependencies.

## Problem
Manual smoke tests show that Qwen3 1.7B can behave like a generic synonym generator or typo-corrector instead of a contextual text editor. Example failure: `срал` in a toilet context produced `сжал`/`сжимал`.

## Scope
- Rewrite the system/user prompt around contextual replacement, not generic synonym generation.
- Require insertable replacements that preserve sentence meaning.
- Make the model self-check candidates before returning JSON, but keep reasoning hidden.
- Preserve current latency profile: no mandatory extra request and no bigger model.
- Keep retry only for fewer than five usable suggestions.

## Out of Scope
- Dictionary or morphology engine.
- Model picker UI.
- Downloading new models.
- Changing popup UI.

## Acceptance Criteria
- Prompt makes the model act as a contextual Russian editor.
- Prompt explicitly rejects spelling/typo correction to visually similar words.
- Prompt asks for candidates that can be inserted into the original sentence.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
