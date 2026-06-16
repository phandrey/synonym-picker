# SPM-036 Fullscreen Overlay Clickaway Quality Audit

## Status
- State: active
- Phase: M2/M3 Interaction + Local Model
- Created: 2026-06-09

## Goal
Fix the suggestions popup for fullscreen Telegram/Chrome spaces, dismiss it when the user clicks elsewhere, and run a 50-case Russian contextual synonym benchmark against the current model-first path.

## Problem
Manual testing after the Qwen3 4B build showed:
- the popup appears above normal Telegram/Chrome windows;
- the popup does not appear above Telegram/Chrome when those apps are in macOS fullscreen;
- the popup remains visible if the user does not choose a suggestion and clicks somewhere else;
- the model quality needs a broader 50-case smoke audit beyond the original small fixture.

## Scope
- Convert the suggestions panel to a non-activating overlay panel suitable for another app's fullscreen Space.
- Avoid activating SynonymPicker when showing suggestions over a source app.
- Keep high overlay window level and cross-application/fullscreen collection behavior.
- Add local/global mouse monitors that dismiss the popup when a click lands outside the panel.
- Add a 50-case Russian benchmark fixture covering verbs, adverbs, adjectives, nouns, context ambiguity, informal text, and edge cases.
- Run the 50-case benchmark against Qwen3 4B and summarize quality risks.
- Run the standard verify gate and reinstall the app.

## Out of Scope
- Public signing/notarization.
- Full automated UI testing inside Telegram/Chrome fullscreen spaces.
- Full morphology engine.
- Replacing Qwen3 4B unless the 50-case audit shows a severe quality regression.

## Acceptance Criteria
- Suggestions panel no longer activates SynonymPicker just to display results.
- Suggestions panel uses a non-activating AppKit panel style.
- Clicking outside the popup dismisses it.
- Existing keyboard/mouse selection behavior remains compile-safe.
- `./scripts/verify.sh` passes.
- `/Applications/SynonymPicker.app` is reinstalled.
- 50-case benchmark is run and summarized in status.

## Verify Gate
- `./scripts/verify.sh`
- `node --check scripts/benchmark-models.mjs`
- `SYNONYM_PICKER_MODEL='Qwen/Qwen3-4B-GGUF:Q4_K_M' node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-50.json`
- `./scripts/install-local.sh`
