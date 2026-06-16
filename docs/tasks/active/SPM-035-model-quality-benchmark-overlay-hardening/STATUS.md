# SPM-035 Model Quality Benchmark Overlay Hardening Status

## Current State
- active

## Done
- Created active task docs.
- Confirmed current default model is still `Qwen3 1.7B`.
- Confirmed current request timeout is `2.8` seconds.
- Confirmed current popup collection behavior still includes `.transient`.
- Switched default profile to `T-Lite IT 1.0 Q4_K_S`.
- Added candidate profiles for `Qwen2.5 7B`, `Qwen3 4B`, `Qwen3 8B`, and legacy `Qwen3 1.7B`.
- Switched default profile from T-Lite to `Qwen3 4B Q4_K_M` after benchmark comparison.
- Added shared llama-server launch arguments `-ngl 99 -c 2048` to model profiles.
- Increased model request/runtime waits to the 5 second budget.
- Changed model prompt/request to strict `{"synonyms":[...]}` JSON object output with `response_format`.
- Added parser support for `{"synonyms":[...]}` string and ranked-object arrays.
- Added parser support for markdown-wrapped `{"synonyms":[...]}` objects.
- Updated app prompt examples to use the same `{"synonyms":[...]}` object format requested from the model.
- Added adverb post-processing guard so `быстро` rejects adjective forms like `быстрый`.
- Hardened popup collection behavior with `.canJoinAllApplications` and removed `.transient`.
- Added Russian synonym benchmark fixture and `scripts/benchmark-models.mjs`.
- Updated `docs/MODELS.md`.
- `./scripts/verify.sh` passed.
- `node --check scripts/benchmark-models.mjs` passed.
- Installed rebuilt `/Applications/SynonymPicker.app`.
- Started `DefaultDF/T-Lite-It-1.0-Quants-GGUF:Q4_K_S`; model downloaded and server reached ready state.
- Ran benchmark against T-Lite.
- Ran benchmark against `Qwen3 4B`; first pass was fast but quality was weak.
- Updated benchmark prompt to mirror the app's full provider prompt more closely.
- Re-ran `Qwen3 4B` benchmark with app-like prompt: key verb cases passed within 5 seconds.

## In Progress
- Awaiting manual app smoke test in Telegram and other target apps.

## Next
- Re-grant Accessibility if macOS reset trust after the ad-hoc reinstall.
- Manual Telegram smoke test for synonym quality and popup visibility.
- If Telegram overlay still fails, continue with a narrower window-level/focus investigation.

## Decisions
- Use model-first only. No fast synonym dictionary will be reintroduced.
- Use a 5 second interaction budget because the user approved a slower response if it improves quality.
- Use `Qwen3 4B Q4_K_M` as the default profile: T-Lite failed key smoke tests; Qwen3 4B passed `попробуем`, `переделывал`, `стандартные`, `сложные`, and `хорошо` within the 5 second budget after using the app-like prompt.
- Keep `Qwen3 1.7B` only as a legacy fast fallback, not as default.

## Blockers
- T-Lite is not acceptable as default based on benchmark: `попробуем` timed out at 5 seconds, `переделывал` returned imperative/same-lexeme forms, `быстро` returned `source - synonym` strings, and responses were often markdown-wrapped despite `response_format`.
- Server-level `--json-schema` is not usable with the current `llama-server` setup: requests returned `HTTP 400 Failed to initialize samplers`.
- Stable signing remains tracked separately in `SPM-019`; current install is still ad-hoc signed.
- Manual Telegram overlay smoke has not been performed by the user yet.

## Verify Log
- 2026-06-08: first `./scripts/verify.sh` failed on missing Swift `return` in `SynonymResponseParser`.
- 2026-06-08: `./scripts/verify.sh` passed: lint, typecheck/build, 32 tests, app bundle.
- 2026-06-08: `node --check scripts/benchmark-models.mjs` passed.
- 2026-06-08: `./scripts/install-local.sh` passed and installed `/Applications/SynonymPicker.app`; bundle remains ad-hoc signed.
- 2026-06-08: local endpoint health-check failed with connection refused.
- 2026-06-09: user approved starting/downloading the selected local model for benchmark validation.
- 2026-06-09: T-Lite downloaded and served on `127.0.0.1:8080`.
- 2026-06-09: `node scripts/benchmark-models.mjs` against T-Lite completed; quality failed for key verb/output-format cases.
- 2026-06-09: server-level `--json-schema` experiment failed with `HTTP 400 Failed to initialize samplers`; code/docs reverted to no server-level schema.
- 2026-06-09: first `Qwen3 4B` benchmark pass was fast but weak; benchmark prompt was then updated to match the app prompt more closely before final model comparison.
- 2026-06-09: second `Qwen3 4B` benchmark with app-like prompt: `попробуем` 4208 ms -> `попытаемся/проверим/протестируем`; `переделывал` 1227 ms -> `исправлял/дорабатывал/перерабатывал`; most other cases under 1.2 seconds.
- 2026-06-09: `./scripts/verify.sh` passed after final changes: lint, typecheck/build, 34 tests, app bundle.
- 2026-06-09: `./scripts/install-local.sh` passed and installed `/Applications/SynonymPicker.app`; bundle remains ad-hoc signed.
- 2026-06-09: stopped benchmark `llama-server`; port `8080` is no longer occupied by the test process.
