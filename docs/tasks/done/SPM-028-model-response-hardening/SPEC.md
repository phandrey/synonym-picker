# SPM-028 Model Response Hardening

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Stop usable model responses from collapsing into `Local model did not return usable synonyms` on common Russian adjective cases.

## Problem
Smoke test for `веселый` shows the app can report no usable suggestions even when the local model server is running. Likely causes are parser brittleness, same-word variants, and missing grammatical guardrails for adjective forms.

## Scope
- Make response parsing robust to common object keys beyond `word`/`synonym`.
- Keep old string-array parsing.
- Add lightweight grammatical compatibility filtering for Russian adjective-like words.
- Improve user-facing failure message when the model is reachable but suggestions are unusable.
- Keep speed roughly unchanged.

## Out of Scope
- Full morphology engine.
- Dictionary/thesaurus integration.
- New model.
- Popup redesign.

## Acceptance Criteria
- Parser handles object keys such as `variant`, `replacement`, `слово`, `синоним`, `замена`.
- Adjective smoke-test cases reject obvious wrong-form verbs.
- `веселый`/`весёлый` remains filtered as same word.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
