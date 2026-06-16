# SPM-030 Compact Context Quality Prompt

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-05

## Goal
Incorporate the useful parts of the proposed context-editor prompt without slowing the local model by requiring verbose scoring JSON.

## Problem
The proposed prompt correctly emphasizes context, grammar, style, tone, collocation, and whole-sentence fit. But returning full context analysis, scores, categories, comments, and sentence rewrites would increase output tokens and latency on Qwen 1.7B.

## Scope
- Extract and pass the selected sentence separately from the wider context window.
- Keep the wider context window compact.
- Update the model prompt with concise hidden quality criteria:
  - meaning in context;
  - part of speech and grammar form;
  - style/tone/formality;
  - linked neighbor words/collocation;
  - whole-sentence naturalness;
  - avoid over-literary replacements.
- Keep output as a short JSON array of replacement strings.
- Keep local fast lexicon behavior unchanged.

## Out of Scope
- Verbose scoring JSON output.
- Returning full sentence rewrites in the popup.
- Multi-token phrase replacement behavior changes.
- New model or dictionary integration.

## Acceptance Criteria
- `TextContext` can carry both compact context and selected sentence.
- Prompt includes `Предложение` separately when available.
- Model output format remains JSON array of strings.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
