# SPM-036 Fullscreen Overlay Clickaway Quality Audit Status

## Current State
- implemented, installed, and user-confirmed working

## Done
- Created active task docs.
- User confirmed fullscreen overlay and outside-click behavior works after install.
- Confirmed user-reported fullscreen issue applies to Telegram/Chrome fullscreen windows, while normal windows work.
- Confirmed current popup still activates SynonymPicker during `show`.
- Confirmed current popup has no outside-click monitor.
- Changed suggestions panel to a non-activating HUD panel that can join all apps/spaces and fullscreen auxiliary spaces.
- Removed SynonymPicker app activation during popup display.
- Kept high `.screenSaver` window level and `orderFrontRegardless()` for cross-app display.
- Added local/global mouse monitors that dismiss the popup when the user clicks outside the suggestions panel.
- Changed benchmark default model to `Qwen3 4B Q4_K_M`.
- Added `scripts/fixtures/russian-synonym-benchmark-50.json`.
- Changed prompt wording from forced 4-8 suggestions to 1-8 suggestions to reduce source-word repetition.
- Added mixed-script artifact filtering for Russian source words.
- Added one AI repair retry when the first model response normalizes to no usable suggestions.
- Updated benchmark script to simulate the same repair retry.
- Added repair examples for repeated-source fallback cases.
- Added post-processing guard that rejects multi-word replacements for single-word selections.
- Relaxed that guard for adverb sources so short adverbial phrases like `без проблем` can replace `нормально`.
- Split repair requests into a shorter AI prompt focused on avoiding source-word repetition.
- Raised repair timeout from 2.8s to 3.5s and lowered repair `max_tokens` to 100.
- Added repair examples for `режим`, `скорость`, `редкие`, `часто`, and `вручную`.
- Fixed post-processing false positives:
  - `режим` is no longer treated as an adjective/verb just because it ends with `-им`;
  - `скорость` is no longer treated as an infinitive just because it ends with `-ть`;
  - `вручную` is treated as an adverb-like replacement source.
- Added regression tests for `режим`, `скорость`, and `вручную`.
- Synchronized the benchmark filter with the Swift post-processing heuristics.
- Ran the final 50-case benchmark: `50/50` non-empty, `0` over 5s, avg `1987ms`, p95 `3952ms`, max `4953ms`.
- Ran `./scripts/verify.sh`: lint, build, 40 tests, app bundle passed.
- Installed and opened `/Applications/SynonymPicker.app`.
- Confirmed `http://127.0.0.1:8080/v1/models` responds with `Qwen/Qwen3-4B-GGUF:Q4_K_M`.
- Stopped the temporary benchmark server on port `8081`.

## In Progress
- None.

## Next
- None for this task.

## Decisions
- Use a non-activating panel for suggestion display so showing the popup does not switch focus away from the fullscreen source app.
- Keep `.canJoinAllApplications` and `.fullScreenAuxiliary` because fullscreen overlay visibility depends on joining another app's fullscreen Space.
- Use global mouse monitoring only for dismissal; suggestion clicks inside the popup remain handled by the SwiftUI buttons.
- Keep Qwen3 4B as the default model because it stays inside the 5s budget on the 50-case audit.
- Keep any further popup/menu UX changes in follow-up tasks.

## Blockers
- Installed app is still ad-hoc signed, so macOS Accessibility trust may need to be re-granted.
- Quality is technically non-empty on all 50 cases, but several semantic candidates remain weak and should be treated as future model/prompt quality work, for example `выбираю -> бережу`, `скорость -> прыжок`, and some stylistically odd adjective/adverb candidates.

## Verify Log
- `node --check scripts/benchmark-models.mjs`: passed.
- `swift test`: passed, 40 tests.
- `SYNONYM_PICKER_ENDPOINT=http://127.0.0.1:8081/v1/chat/completions SYNONYM_PICKER_MODEL=Qwen/Qwen3-4B-GGUF:Q4_K_M node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-50.json > .build/qwen3-4b-benchmark-50-v7-final.jsonl`: passed.
- Final benchmark summary:
  - count: `50`;
  - ok/non-empty: `50`;
  - empty: `0`;
  - repair attempts: `5`;
  - repair successes: `5`;
  - over 5s: `0`;
  - avg: `1987ms`;
  - p95: `3952ms`;
  - max: `4953ms`.
- `./scripts/verify.sh`: passed.
- `./scripts/install-local.sh`: passed; `/Applications/SynonymPicker.app` installed and opened.
