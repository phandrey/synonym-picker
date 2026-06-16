# SPM-038 Public GitHub Release Prep

## Status
- State: active
- Phase: Packaging + Runtime UX + Quality
- Created: 2026-06-10

## Goal
Prepare Synonym Picker for a public GitHub source release while preserving current app behavior and making first-run model setup understandable from the status bar menu.

## Scope
- Preserve existing synonym selection/replacement functionality.
- Make the status menu model row active before the model is downloaded.
- Show a model download action on first run.
- Show download progress while the model is being fetched locally.
- Show a check mark once the model is available.
- Change the selected synonym row highlight from dark blue to dark pink/magenta aligned with the app mark.
- Add another diverse 50-case Russian synonym benchmark fixture and run it.
- Fix practical issues discovered by the new benchmark where scoped and safe.
- Update README/model/install docs so GitHub users can download the repo and install locally.

## Out of Scope
- Shipping GGUF model weights in git.
- Notarized public `.dmg`/`.pkg` distribution.
- Automatic Homebrew installation without user action.
- Full semantic reranker architecture.

## Acceptance Criteria
- Existing hotkey, overlay, replacement, and AI lookup flow still builds and tests.
- Status menu model row:
  - is clickable when the model is missing;
  - shows progress while downloading;
  - shows a check mark when downloaded/ready.
- Selected synonym highlight is dark pink, not system blue.
- A new 50-case benchmark is committed under `scripts/fixtures/`.
- `./scripts/verify.sh` passes.
- README explains GitHub `Code` zip install and the recommended GitHub Releases path.
- `/Applications/SynonymPicker.app` is reinstalled for local smoke testing.
