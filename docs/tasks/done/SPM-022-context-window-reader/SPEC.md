# SPM-022 Context Window Reader

## Status
- State: backlog
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Send the local model the selected word plus nearby text context so suggestions match the actual meaning and grammar in the sentence.

## Scope
- Capture a small context window around the selected word.
- Target roughly three nearby sentences when the source app allows it.
- Preserve the current selected word replacement behavior.
- Pass context into `LocalSynonymProvider`.
- Update prompt to use context for sense disambiguation and grammar.

## Out of Scope
- Full document parsing.
- Dictionary integration.
- Public release packaging.

## Notes
- Current MVP reads only selected text through copy fallback.
- Implementation needs careful clipboard/selection handling because macOS apps expose context differently.
