# Models

Synonym Picker does not bundle or commit model weights.

## Default Profile

- Model: `Qwen3 4B Q4_K_M`
- Server model id: `Qwen/Qwen3-4B-GGUF:Q4_K_M`
- Source: `Qwen/Qwen3-4B-GGUF`
- Approximate GGUF size: `2.33 GB`
- Runtime: `llama.cpp`
- Endpoint expected by the app: `http://127.0.0.1:8080/v1/chat/completions`

Install runtime:

```sh
brew install llama.cpp
```

## First-Run Download Flow

On launch, Synonym Picker checks the local Hugging Face cache:

```text
~/.cache/huggingface/hub/models--Qwen--Qwen3-4B-GGUF/
```

If the default GGUF is missing, the menu bar model row becomes active:

```text
Model: Qwen3 4B  ↓ Download
```

Clicking it starts `llama-server -hf Qwen/Qwen3-4B-GGUF:Q4_K_M`.
`llama-server` downloads the model into the local cache and then serves it.
The app estimates progress from the cache size and shows a percent in the menu.
When the server is ready, the row becomes:

```text
Model: Qwen3 4B  ✓
```

If another compatible `llama-server` is already responding on port `8080`, the
app uses it and does not start a duplicate process.

## Prompt Contract

The app sends `/no_think` in the user prompt and asks for compact JSON:

```json
{"synonyms":["..."]}
```

The response is parsed and post-processed locally before suggestions are shown.

## Candidate Profiles

These are useful for manual benchmarking only:

```sh
llama-server -hf DefaultDF/T-Lite-It-1.0-Quants-GGUF:Q4_K_S -ngl 99 -c 2048
llama-server -hf Qwen/Qwen2.5-7B-Instruct-GGUF:Q4_K_M -ngl 99 -c 2048
llama-server -hf Qwen/Qwen3-8B-GGUF:Q4_K_M -ngl 99 -c 2048
llama-server -hf bartowski/Qwen_Qwen3-1.7B-GGUF:Q4_K_M -ngl 99 -c 2048
```

`Qwen3 1.7B` remains a legacy fast fallback. `T-Lite IT 1.0 Q4_K_S` was tested
but not selected because it produced weaker verb handling and less reliable JSON.

## Benchmarking

With a compatible server already running on port `8080`:

```sh
node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-50.json
node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-public-50.json
```

To benchmark a different served model:

```sh
SYNONYM_PICKER_MODEL="Qwen/Qwen3-8B-GGUF:Q4_K_M" \
  node scripts/benchmark-models.mjs scripts/fixtures/russian-synonym-benchmark-public-50.json
```

## Packaging Rule

Do not commit `.gguf` files, Hugging Face caches, `.build/`, or `dist/`.

Public source releases should contain code and scripts only. For normal end
users, prefer GitHub Releases with a signed/notarized app archive when a stable
Developer ID certificate is available.
