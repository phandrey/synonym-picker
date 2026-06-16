# Synonym Picker for macOS

Local macOS menu bar app for context-aware Russian synonym replacement.

The app reads the selected word and nearby context, asks a local `llama.cpp`
model for replacement candidates, shows a small overlay, and replaces the
selected word in the source app after you choose a synonym.

## Features

- Runs from the macOS menu bar.
- Works with a configurable global hotkey.
- Uses a local model through `llama.cpp`; text is not sent to a cloud API.
- Shows synonym suggestions over the active app, including fullscreen Spaces.
- Replaces the selected word through the clipboard paste flow.
- Downloads the default model on first run from the status bar menu.

## Requirements

- macOS with Apple Silicon.
- Xcode Command Line Tools.
- Homebrew.
- `llama.cpp`.

Install the runtime dependency first:

```sh
xcode-select --install
brew install llama.cpp
```

## Install From GitHub Code Download

The green GitHub `Code` button downloads the source code, not a prebuilt `.app`.
After downloading the ZIP:

1. Unzip the project.
2. Open Terminal in the `synonym-picker-mac` folder.
3. Run:

```sh
./scripts/install.sh
```

The installer builds the app, copies it to `/Applications/SynonymPicker.app`,
removes quarantine metadata, and opens the app.

## Install From DMG

For the simplest install, download `SynonymPicker.dmg` from the latest GitHub
Release, open it, and drag `SynonymPicker.app` into `Applications`.

If macOS blocks the first launch because the app is not notarized yet,
right-click `SynonymPicker.app` and choose `Open`.

The DMG contains the app only. Synonym Picker still needs `llama.cpp` on the
Mac to run local AI inference:

```sh
brew install llama.cpp
```

## First Run

1. Click the sparkle icon in the macOS menu bar.
2. Choose `Hotkey: ...` and press the shortcut you want to use.
3. Choose `Permissions: Request Accessibility` and grant Accessibility access
   to `SynonymPicker`.
4. Choose `Model: Qwen3 4B ↓ Download` if the model is not downloaded yet.
5. Wait until the model row shows a percentage and then `Model: Qwen3 4B ✓`.

After that, select a word in another app and press your hotkey.

## Model

Default model:

- `Qwen/Qwen3-4B-GGUF:Q4_K_M`
- Approximate local size: 2.33 GB
- Runtime: `llama.cpp`
- Local endpoint: `http://127.0.0.1:8080/v1/chat/completions`

Model weights are not committed to git. They are downloaded into the local
Hugging Face cache by `llama-server` when you click the model row in the menu.

See [docs/MODELS.md](docs/MODELS.md).

## Verify Development Build

```sh
./scripts/verify.sh
```

Run the quality benchmark:

```sh
node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-50.json
node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-public-50.json
```

## Publishing Notes

For a simple source release, push this folder to GitHub. Users can download it
with the green `Code` button and run `./scripts/install.sh`.

For a cleaner end-user download, create a GitHub Release and attach a signed or
notarized app archive. The source ZIP from the green `Code` button is useful for
developers, but normal users usually expect a Release asset.

Build a release DMG locally with:

```sh
./scripts/build-dmg.sh
```

Current local builds may be ad-hoc signed unless you create a local signing
identity with:

```sh
./scripts/create-local-codesign-identity.sh
```

## License

This project's source code is licensed under the MIT License. See
[LICENSE](LICENSE).
