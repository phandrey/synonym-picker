# SPM-038 Public GitHub Release Prep Status

## Current State
- implemented and installed; ready for GitHub source handoff

## Done
- Captured user scope for public GitHub source release preparation.
- Decided not to commit GGUF model weights; model download remains local first-run setup.
- Implemented first-run model menu state:
  - model row is active when the model is missing;
  - row shows download, progress percent, ready checkmark, missing-runtime, and retry states;
  - hotkey use without the model now tells the user to download the model from the menu bar.
- Added model cache detection for `Qwen/Qwen3-4B-GGUF:Q4_K_M`.
- Changed selected synonym highlight from dark blue to logo-like dark pink.
- Added public install path:
  - `scripts/install.sh` checks Swift toolchain and `llama-server`;
  - `scripts/install-local.sh` message now points users to menu bar `Permissions: Request Accessibility`.
- Updated public docs:
  - `README.md` explains GitHub `Code` source download, local install, first-run model download, and release caveats;
  - `docs/MODELS.md` explains default model, cache behavior, first-run download, and benchmarking.
- Added `.gitignore` for `.build`, `dist`, logs, and local/system artifacts.
- Added stricter synonym post-processing:
  - rejects phrase candidates that include the source word;
  - rejects verb candidates for noun sources;
  - handles `репозиторий` as noun, `напрямую` as adverb, and same-lexeme reflexive verbs such as `появится -> появляется`.
- Added regression tests for public-release filter cases.
- Ran multiple 50-case public benchmark passes while fixing prompt/filter issues; final heavy benchmark was stopped at user request to avoid extra computer load.
- Ran `./scripts/verify.sh` successfully after the last code change.
- Installed and opened `/Applications/SynonymPicker.app`.
- Hotfixed fullscreen overlay regression:
  - popup no longer calls `makeKeyAndOrderFront(nil)` when shown;
  - popup keeps `.screenSaver` level and `orderFrontRegardless()` for fullscreen Spaces;
  - `NSPanel.becomesKeyOnlyIfNeeded = true` reduces focus/Space switching risk.
- Re-ran `./scripts/verify.sh` after the fullscreen hotfix.
- Reinstalled and opened `/Applications/SynonymPicker.app` after the fullscreen hotfix.
- Re-ran `./scripts/verify.sh` on 2026-06-16 before GitHub push guidance; lint, build, 45 tests, and app bundle passed.
- Tightened `.gitignore` for public repo safety: local Swift/Xcode artifacts, env files, GGUF model weights, app/package archives, and signing artifacts are ignored.

## In Progress
- None.

## Next
- Push source to GitHub when the user is ready.
- Optional later: create a GitHub Release with a signed/notarized `.app` archive for one-click user downloads.

## Decisions
- GitHub green `Code` downloads source, not a signed app binary; README should explain source install from zip and recommend GitHub Releases for future one-file app downloads.
- Keep `Qwen3 4B Q4_K_M` as the public default model.
- Keep model weights out of git; first launch downloads the GGUF into the user's Hugging Face cache.
- Do not run more model benchmark passes in this session unless explicitly requested again; they are CPU-heavy.

## Blockers
- Notarized distribution remains out of scope until a Developer ID certificate exists.
- Current installed bundle is still ad-hoc signed, so macOS Accessibility trust can reset after reinstall.

## Verify Log
- `./scripts/verify.sh`: passed after final changes; lint, typecheck/build, 45 tests, app bundle.
- `node --check scripts/benchmark-models.mjs`: passed.
- `./scripts/install-local.sh`: passed; installed `/Applications/SynonymPicker.app` and opened it.
- `./scripts/verify.sh`: passed after fullscreen overlay hotfix; lint, typecheck/build, 45 tests, app bundle.
- `./scripts/install-local.sh`: passed after fullscreen overlay hotfix; installed `/Applications/SynonymPicker.app` and opened it.
- `./scripts/verify.sh`: passed on 2026-06-16 for GitHub push readiness; lint, typecheck/build, 45 tests, app bundle.
- Model benchmark note:
  - complete public 50-case runs were used to diagnose and fix repeated source-word outputs, same-lexeme forms, noun/adverb classification, and timeout pressure;
  - the final long benchmark pass was stopped by user request because it was consuming too many local resources.
