# SPM-025 Contextual Ranking Leaderboard

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Rank generated synonym candidates by contextual fit so the popup shows the best insertable replacements first.

## Problem
The current popup order is mostly the model's generation order. Manual smoke tests show that common or generic candidates can appear above better contextual replacements.

## Scope
- Ask the local model to return candidate replacements with a numeric contextual fit score.
- Parse both ranked object JSON and legacy string-array JSON.
- Sort candidates locally by score before showing them.
- Keep the existing fallback/retry behavior.
- Preserve speed: do not add a mandatory second model request.

## Out of Scope
- Online frequency lookup.
- External web APIs.
- Dictionary/morphology engine.
- Visual score UI in the popup.

## Acceptance Criteria
- Provider can parse ranked JSON candidates.
- Provider returns suggestions sorted by contextual score.
- Legacy string responses still work.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
