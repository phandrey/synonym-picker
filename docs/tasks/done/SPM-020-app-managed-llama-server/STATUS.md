# SPM-020 App Managed Llama Server Status

## Current State
- done

## Done
- SPEC created.
- Root cause confirmed: llama-server started from Codex tool foreground works, but detached background process does not persist reliably from the tool environment.
- Added `LlamaServerManager`.
- App starts the default fast `llama-server` profile on launch when no server is already available.
- App does not start a duplicate when `/v1/models` is already responding on port `8080`.
- Model tile now reports `Missing`, `Starting`, `External`, `Ready`, or `Failed`.
- Hotkey flow waits for the managed runtime before calling the local synonym provider.
- `docs/MODELS.md` documents the app-managed runtime behavior.

## In Progress
- None.

## Next
- Reinstall local app and smoke test model popup.

## Blockers
- None.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed:
  - lint
  - typecheck/build
  - tests (`6/6`)
  - app bundle
