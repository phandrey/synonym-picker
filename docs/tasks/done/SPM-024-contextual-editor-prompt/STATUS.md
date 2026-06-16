# SPM-024 Contextual Editor Prompt Status

## Current State
- done

## Done
- SPEC created.
- Constraint set: keep speed roughly the same by improving prompt only.
- Prompt now frames the model as a contextual Russian editor instead of a generic synonym generator.
- Prompt asks for insertable replacements that preserve sentence meaning.
- Prompt requires hidden self-check before JSON output.
- Prompt explicitly rejects typo-correction to visually similar words, including `срал` -> `сжал`/`сжимал`.
- Prompt preserves colloquial/obscene meaning instead of sanitizing it.
- Temperature reduced to make the fast model less random:
  - first pass `0.35`;
  - retry `0.55`.

## In Progress
- None.

## Next
- Reinstall and smoke test `срал`, `глупо`, `легкий`, `грустную`.
- If model still fails semantic cases, activate `SPM-023-lexical-quality-engine`.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`11/11`)
  - app bundle
