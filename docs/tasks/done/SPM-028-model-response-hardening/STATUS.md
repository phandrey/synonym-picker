# SPM-028 Model Response Hardening Status

## Current State
- done

## Done
- SPEC created.
- Likely failure points identified:
  - ranked-object parser is too narrow;
  - adjective selected words lack a grammar-shape guard;
  - UI message says `Model not ready` for unusable suggestions.
- Moved response parsing into `SynonymPickerCore` so it can be unit-tested.
- Parser now supports string arrays, embedded JSON arrays, ranked object aliases, and Russian object keys.
- Prompt now explicitly treats `е`/`ё` variants as the same source word and gives compact Russian examples.
- Post-processing now rejects wrong-form adjective candidates while preserving same-form adjective candidates.
- UI failure for reachable-but-unusable model output now uses `No usable synonyms` instead of `Model not ready`.
- Verify gate passed.

## In Progress
- None.

## Next
- Reinstall and smoke test `веселый`, `смешной`, `классные`, `скучный`.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed: lint, typecheck/build, 21 tests, app bundle.
