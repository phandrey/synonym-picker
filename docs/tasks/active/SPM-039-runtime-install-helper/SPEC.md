# SPM-039 Runtime Install Helper

## Status
- State: active
- Phase: DMG First-Run UX
- Created: 2026-06-16

## Goal
Make the DMG install path usable for non-developer users by letting the model menu guide them through installing `llama.cpp` when the runtime is missing, then continue into the default Qwen model download.

## Scope
- Keep runtime installation explicit and user-approved.
- Enable the model menu item when `llama.cpp` is missing.
- Show a confirmation dialog before opening Terminal.
- Open Terminal with a generated `brew install llama.cpp` command script.
- Poll for `llama-server` after the installer starts.
- Automatically continue the model download once `llama-server` appears.
- Update README/DMG instructions.

## Out of Scope
- Silent background package installation.
- Bundling `llama.cpp` inside the app.
- Installing Homebrew automatically.
- Developer ID signing/notarization.

## Acceptance Criteria
- Missing-runtime menu row is clickable.
- User sees an explicit install confirmation before any Terminal command is launched.
- If Homebrew is missing, the app explains that Homebrew must be installed first and offers to open `brew.sh`.
- If Homebrew exists, Terminal opens a readable installer script for `brew install llama.cpp`.
- After runtime installation, the app starts the existing Qwen download flow.
- `./scripts/verify.sh` passes.
- `./scripts/build-dmg.sh` creates and verifies a DMG.
