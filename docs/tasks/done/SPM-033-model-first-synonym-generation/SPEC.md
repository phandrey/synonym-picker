# SPM-033 Model First Synonym Generation

## Status
- State: done
- Phase: M3 Local Model
- Created: 2026-06-05

## Goal
Make every synonym lookup use the local AI model as the source of suggestions while keeping the hotkey path within roughly 2-3 seconds when the model server is already warm.

## Problem
The previous fast lexical layer made common words feel stable, but it also meant those lookups did not use the model at all. That contradicts the desired product behavior: suggestions should be generated from context every time, not selected from a manually maintained synonym list.

## Scope
- Remove the fast lexical shortcut from the provider path.
- Remove the fast synonym lexicon source and tests.
- Use one model request per lookup.
- Remove retry logic that could push latency beyond 2-3 seconds.
- Keep parser and post-processing hardening for model responses.
- Reduce hotkey runtime wait from 8 seconds to 2.5 seconds for cold/unavailable model states.

## Out of Scope
- New model selection UI.
- Larger default model.
- Full Russian morphology engine.
- Killing or managing external user-started `llama-server` processes outside the app-managed lifecycle.

## Acceptance Criteria
- `LocalSynonymProvider` does not call a fast lexicon before requesting the model.
- No `FastSynonymLexicon` source remains in `Sources` or `Tests`.
- A lookup performs at most one model completion request.
- Existing parser/post-processor tests pass.
- App bundle builds.

## Verify Gate
- `./scripts/verify.sh`
