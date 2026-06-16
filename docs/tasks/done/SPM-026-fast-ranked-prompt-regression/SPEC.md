# SPM-026 Fast Ranked Prompt Regression

## Status
- State: active
- Phase: M3 Local Model
- Created: 2026-06-04

## Goal
Fix the latency and one-result regression introduced by ranked JSON object responses while keeping contextual ordering.

## Problem
Manual smoke test shows the latest ranked response format makes the fast local model slow and it can return only one usable option. It also allowed `весёлый` as a duplicate of selected `веселый`.

## Scope
- Replace heavy `{word, score}` prompt with a lighter ordered string-array prompt.
- Keep ranked parser compatibility for future use.
- Preserve local score sorting when scores are present.
- Fix `е/ё` duplicate detection.
- Keep retry only when fewer than five usable suggestions remain.

## Out of Scope
- Dictionary/morphology engine.
- Visual score UI.
- New model.

## Acceptance Criteria
- Prompt asks for an ordered leaderboard as a JSON array of strings.
- Provider response size is reduced versus scored objects.
- `веселый` and `весёлый` are treated as duplicates.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`
