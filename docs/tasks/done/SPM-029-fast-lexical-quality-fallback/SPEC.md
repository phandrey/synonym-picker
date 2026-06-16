# SPM-029 Fast Lexical Quality Fallback

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-05

## Goal
Make common Russian synonym requests faster and more stable, especially for repeated smoke-test cases like `хорошо` and `вкусным`.

## Problem
The local Qwen model is inconsistent for simple Russian synonym cases:
- it can return generic phrases instead of same-part-of-speech replacements;
- it can return base adjective forms that are then filtered out;
- repeated calls for the same context can produce very different quality;
- latency feels worse than expected for common words.

## Scope
- Add a small local lexical seed list for common smoke-test words.
- Return local seed suggestions immediately when enough high-quality candidates are available.
- Keep the local model as fallback for unknown words.
- Add lightweight adjective-form adaptation so model/lexicon candidates like `аппетитный` can become `аппетитным`.
- Tighten prompt to avoid greetings, sentence continuations, and wrong part-of-speech output.
- Keep repo/model size unchanged.

## Out of Scope
- Full Russian morphology engine.
- Internet-backed synonym frequency.
- New model download or model switching UI.
- Public release packaging.

## Acceptance Criteria
- `хорошо` returns stable one-word adverb-like replacements, not greetings.
- `вкусным` can return at least five same-form adjective replacements quickly.
- Existing model fallback still works for words outside the seed list.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
