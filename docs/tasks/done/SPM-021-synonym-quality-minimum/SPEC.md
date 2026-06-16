# SPM-021 Synonym Quality Minimum

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Improve MVP synonym quality so the popup normally shows at least five useful Russian alternatives with more stylistic variety and better grammatical fit.

## Problem
Manual smoke tests show the local model can return too few suggestions, near-duplicates of the selected word, bland variants, or words in the wrong grammatical form.

## Scope
- Ask the model for more diverse real Russian synonyms.
- Require the same part of speech and grammatical form where possible.
- Retry once when fewer than five usable suggestions remain after post-processing.
- Strengthen post-processing against near-duplicates and invented/invalid-looking values.
- Keep the current model and local server architecture.

## Out of Scope
- Reading surrounding context around the selected word.
- Download UI or switching models.
- Dictionary integration.
- Morphological analyzer dependency.

## Acceptance Criteria
- Provider requests enough candidates to fill at least five visible suggestions in normal cases.
- Provider retries once when fewer than five normalized suggestions are available.
- Post-processing filters exact duplicates, selected word variants, and obvious non-word values.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
