# SPM-039 Runtime Install Helper Status

## Current State
- implemented, validated, ready to publish

## Done
- Captured runtime helper scope for DMG first-run UX.
- Added a RuntimeInstaller that prompts before opening Terminal.
- Missing runtime model row is clickable.
- Homebrew-missing flow opens `brew.sh` or copies the Homebrew install command.
- Homebrew-present flow opens a generated `brew install llama.cpp` Terminal script.
- App polls for `llama-server` after installer launch and continues the Qwen model download.
- README and DMG readme explain the new runtime install flow.
- `./scripts/verify.sh` passed after implementation.
- `./scripts/build-dmg.sh` created and verified `dist/SynonymPicker.dmg`.
- Mounted DMG content check passed: `SynonymPicker.app`, `Applications` shortcut, and `Read Me.txt` are present.
- `codesign --verify --deep --strict` passed for the app inside the mounted DMG.

## In Progress
- None.

## Next
- Implement runtime installer helper.
- Push to GitHub.

## Decisions
- Do not run `brew install llama.cpp` silently.
- Use Terminal for the install command so users can see what is happening and enter credentials if Homebrew needs them.
- Do not install Homebrew automatically; open `brew.sh` if Homebrew is missing.

## Blockers
- None.
