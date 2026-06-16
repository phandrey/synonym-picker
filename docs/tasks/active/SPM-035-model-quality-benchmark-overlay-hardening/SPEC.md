# SPM-035 Model Quality Benchmark Overlay Hardening

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-08

## Goal
Make model-first synonym generation usable for Russian contextual replacements while keeping hotkey latency within the user-approved 5 second budget, and harden the popup so it can appear above Telegram and other foreground apps.

## Problem
Manual smoke tests showed that the current local setup still fails product expectations:
- the default `Qwen3 1.7B` profile is too weak for nuanced Russian context;
- model output can be valid JSON-like text but structurally inconsistent enough to increase filtering failures;
- finite verbs still depend too much on prompt compliance;
- the popup can be hidden behind Telegram or other apps;
- there is no repeatable benchmark set for comparing model quality and latency.

## Scope
- Switch the default model profile from the tiny fast model to a Russian-oriented quality profile that can still fit the 5 second target after warmup.
- Add alternate model profiles researched for Russian synonym quality and local GGUF serving.
- Increase request/runtime wait budgets from the previous 2-3 second target to the new 5 second target.
- Request a stricter JSON object response from the local OpenAI-compatible endpoint.
- Teach the parser to read the stricter response object format.
- Add a repeatable benchmark fixture and script for Russian examples.
- Harden the suggestions panel collection behavior for cross-application overlay visibility.
- Update model documentation and task memory/status.
- Run the normal verify gate.

## Out of Scope
- Bundling GGUF weights in the app.
- Full Russian morphology engine or external Python service.
- Public signing/notarization.
- Automatically killing a user-managed external `llama-server`.
- Guaranteeing overlay behavior above every protected/fullscreen/system surface macOS can create.

## Acceptance Criteria
- App defaults to a stronger model profile than `Qwen3 1.7B`.
- `ModelCatalog` lists at least T-Lite, Qwen2.5 7B, Qwen3 4B, and Qwen3 8B candidates.
- Model request timeout and hotkey runtime wait allow up to about 5 seconds.
- Chat request asks for a strict JSON object with a `synonyms` array.
- `SynonymResponseParser` parses `{"synonyms":[...]}` and ranked objects inside that array.
- Benchmark fixture covers the user-reported cases: `попробуем`, `переделывал`, `стандартные`, `локальные`, `свежая`.
- Benchmark script can call the local endpoint and print latency plus raw/filtered results without changing app behavior.
- Popup no longer uses `.transient` and uses `.canJoinAllApplications` where available.
- `./scripts/verify.sh` passes.

## Verify Gate
- `./scripts/verify.sh`
- Optional manual after install: Telegram smoke test for `попробуем`, `переделывал`, `попробуем такую хорошую вариацию`, and popup visibility over Telegram.
