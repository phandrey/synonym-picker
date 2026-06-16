# SPM-032 Parser Lexicon Quality Hardening

## Status
- State: done
- Phase: M3 Local Model
- Created: 2026-06-05

## Goal
Reduce `No usable synonyms` and malformed suggestions for screenshot cases where the model or fast layer fails on common Russian adjective forms.

## Problem
Manual screenshots show three connected failure modes:
- simple covered words feel non-AI because the fast lexical layer returns immediately;
- uncovered words such as `стандартные` and `локальные` fall through to the small local model and can be filtered to zero;
- the model may return plain comma-separated text instead of JSON, which previously became one invalid candidate and was filtered out.

## Scope
- Parse comma-separated plain text and labeled plain text responses from the local model.
- Add fast lexical coverage for `стандартный`, `локальный`, and `свежий`.
- Fix adjective lemma lookup for hard/soft ambiguous endings such as `свежая -> свежий`.
- Fix adjective shape adaptation for velar stems such as `мягкий -> мягкая`.
- Add regression tests for screenshot cases.

## Out of Scope
- Full Russian thesaurus import.
- Full morphology engine.
- Model replacement or bigger model default.
- UI redesign.

## Acceptance Criteria
- `стандартные`, `локальные`, and `свежая` return usable suggestions in the fast path.
- Plain responses like `Синонимы: обычные, типовые` are split into individual candidates.
- `мягкий` adapts to `мягкая`, not malformed forms.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
