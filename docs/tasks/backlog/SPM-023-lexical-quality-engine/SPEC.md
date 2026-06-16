# SPM-023 Lexical Quality Engine

## Status
- State: backlog
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Improve synonym quality beyond prompt tuning by combining the local model with lexical resources and Russian morphology.

## Scope
- Evaluate an offline Russian morphology layer for part of speech and inflection.
- Evaluate an offline Russian thesaurus/synonym source.
- Decide whether the app should use:
  - model-only generation;
  - dictionary candidates plus model ranking;
  - model candidates plus dictionary/morphology filtering.
- Keep model files and lexical resources out of the app bundle until the download UI exists.

## Out of Scope
- Shipping large bundled dictionaries in MVP.
- Cloud APIs.
- Public release packaging.

## Notes
- Candidate resources to evaluate: `pymorphy3`, RuWordNet, and OpenOffice/LibreOffice-style Russian thesaurus datasets.
