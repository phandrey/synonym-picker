# SPM-017 Local Model Provider MVP

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-03

## Goal
Replace hardcoded mock suggestions with suggestions returned by a local AI provider, while keeping the GitHub project distributable without bundling model weights.

## Product Direction
- The app binary/repository must not include model files.
- Users should be able to choose/download models later.
- Default fast profile: `Qwen3-1.7B Q4_K_M` via GGUF/llama.cpp.
- Quality profile can be added later with `Qwen3-4B Q4_K_M`.

## Scope
- Add a model catalog with a default fast model and future quality model metadata.
- Add a local OpenAI-compatible inference client pointed at `http://127.0.0.1:8080/v1/chat/completions`.
- Add prompt construction for contextual synonym generation.
- Add response parsing and reuse existing core post-processing.
- Use AI suggestions when provider returns valid suggestions.
- Show a model-not-ready fallback when the local provider is unavailable.
- Update Settings model tile status from hardcoded `Planned`.

## Out of Scope
- Downloading GGUF files from the app.
- Bundling `llama.cpp`.
- Starting/stopping `llama-server` automatically.
- Real public release packaging.
- Force Click trigger.

## Acceptance Criteria
- Hardcoded suggestions are no longer the only path.
- If local provider is available, popup displays AI-returned suggestions.
- If local provider is unavailable, popup shows a clear model-not-ready message.
- Model metadata makes it clear that the model is external and not bundled.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

