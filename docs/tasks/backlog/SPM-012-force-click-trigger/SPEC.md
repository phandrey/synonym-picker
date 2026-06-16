# SPM-012 Force Click Trigger

## Status
- State: backlog
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Explore and implement a Force Click / deep trackpad press trigger for synonym lookup, similar to the macOS dictionary gesture.

## Scope
- Research the correct AppKit/Accessibility event path for Force Click.
- Decide whether this app can observe Force Click globally without a privileged helper.
- If feasible, add Force Click as an optional trigger alongside the configured hotkey.

## Out of Scope
- Replacing the current hotkey trigger.
- Model-backed synonyms.
- Public packaging.

## Acceptance Criteria
- There is a clear implementation decision documented.
- If feasible in the current app architecture, Force Click can trigger the same selection-read and popup flow.
- If not feasible without deeper permissions/helper app, the blocker is documented with the next minimal step.

## Verify Gate
- `./scripts/verify.sh`

