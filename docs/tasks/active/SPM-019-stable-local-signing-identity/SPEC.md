# SPM-019 Stable Local Signing Identity

## Status
- State: active
- Phase: M1 macOS App Foundation
- Created: 2026-06-04

## Goal
Stop macOS Accessibility permission from breaking after each rebuild/reinstall by signing the app with a stable local code-signing identity instead of ad-hoc signing.

## Problem
The app bundle is currently ad-hoc signed. `codesign -dv` shows `Signature=adhoc` and a changing `CDHash`. `security find-identity -v -p codesigning` shows no valid identities. For TCC/Accessibility, each rebuilt ad-hoc app can be treated as a different binary even when the bundle id is the same.

## Scope
- Add a script to create/import a local self-signed code-signing identity.
- Update `scripts/build-app.sh` to use the stable local identity when available.
- Keep ad-hoc signing only as fallback.
- Update local install docs so Accessibility is re-granted once after switching identity.

## Out of Scope
- Apple Developer ID signing.
- Notarization.
- Public release packaging.
- Changing bundle id.

## Acceptance Criteria
- A reusable local identity name is defined.
- Build script signs with that identity if it exists.
- `codesign -dv` can show non-ad-hoc authority after identity creation.
- Verify gate passes.

## Verify Gate
- `./scripts/verify.sh`

