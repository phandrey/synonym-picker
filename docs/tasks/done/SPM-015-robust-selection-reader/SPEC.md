# SPM-015 Robust Selection Reader

## Status
- State: active
- Phase: M2 Core Interaction
- Created: 2026-06-03

## Goal
Make selected-text reading reliable enough for the MVP when Accessibility permission is already granted.

## Problem
The current reader clears the pasteboard, sends Command+C, waits a fixed 180 ms, and reads once. This can fail even with Accessibility granted if the foreground app updates the pasteboard later than 180 ms.

## Scope
- Replace fixed-delay reading with pasteboard `changeCount` polling.
- Wait up to a bounded timeout for the foreground app to copy selected text.
- Preserve and restore the user's clipboard.
- Return more specific failure messages for missing Accessibility permission vs no copied text.
- Keep the existing hotkey, popup, and mock suggestions behavior.

## Out of Scope
- Real model-backed synonyms.
- Force Click trigger.
- Replacing the clipboard-based strategy entirely.
- Public packaging.

## Acceptance Criteria
- The reader waits for actual pasteboard changes after sending Command+C.
- If copied text arrives within timeout, popup shows mock synonyms.
- If no copied text arrives, popup shows a clearer failure reason.
- Existing verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

