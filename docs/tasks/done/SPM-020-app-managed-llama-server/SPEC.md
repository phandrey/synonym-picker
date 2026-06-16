# SPM-020 App Managed Llama Server

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Make Synonym Picker start and keep a local `llama-server` process alive while the app runs, so the user does not need to manage a separate terminal process.

## Scope
- Add a `LlamaServerManager` using external `llama-server` if installed.
- Do not bundle `llama.cpp` or model weights.
- Start default fast profile on app launch when no server is already listening.
- Update model tile status for missing runtime, starting, and external model states.
- Keep OpenAI-compatible provider unchanged except for using the managed server.

## Out of Scope
- Downloading/installing `llama.cpp`.
- Download UI for GGUF files.
- LaunchAgent/background service outside app lifetime.
- Public release packaging.

## Acceptance Criteria
- If `/opt/homebrew/bin/llama-server` or `/usr/local/bin/llama-server` exists, app can start it.
- If port 8080 is already listening, app does not start a duplicate server.
- If runtime is missing, Settings shows a clear model status.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

