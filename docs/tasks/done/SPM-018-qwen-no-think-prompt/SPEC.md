# SPM-018 Qwen No-Think Prompt

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-03

## Goal
Make the local Qwen3 provider return synonyms in the normal chat `content` field quickly, instead of spending the token budget on reasoning output.

## Problem
Manual `/v1/chat/completions` smoke test showed Qwen3 returned an empty `content` and populated `reasoning_content` unless `/no_think` is included in the prompt.

## Scope
- Add `/no_think` to the user prompt sent to Qwen3.
- Increase max output budget slightly so JSON synonyms are not cut off.
- Keep the model external and unbundled.
- Update model docs with the no-think note.

## Acceptance Criteria
- Provider prompt includes `/no_think`.
- Local smoke test against llama-server returns JSON in `content`.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

