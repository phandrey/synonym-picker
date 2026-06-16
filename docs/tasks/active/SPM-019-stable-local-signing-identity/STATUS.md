# SPM-019 Stable Local Signing Identity Status

## Current State
- active

## Done
- SPEC created.
- Root cause confirmed:
  - installed app is ad-hoc signed;
  - no valid code-signing identities exist;
  - ad-hoc `CDHash` changes can invalidate Accessibility trust after rebuild.
- Added `scripts/create-local-codesign-identity.sh`.
- `scripts/build-app.sh` now prefers `SynonymPicker Local Code Signing` when available and falls back to ad-hoc signing.
- `scripts/install-local.sh` no longer resets Accessibility on every install.
- Verify gate passed with ad-hoc fallback.
- Confirmed current installed app is still ad-hoc signed:
  - `codesign -dv /Applications/SynonymPicker.app` shows `Signature=adhoc`.
  - `security find-identity -v -p codesigning` shows `0 valid identities found`.
- Fixed `scripts/build-app.sh` bug where SwiftPM's temporary `HOME=.build/home` leaked into `security`/`codesign` lookup.
- Hardened `scripts/create-local-codesign-identity.sh`:
  - uses the user's default keychain;
  - imports the identity with codesign access;
  - validates that `security find-identity` can see the identity before reporting success.
- Updated `scripts/install-local.sh` to print the installed signature and warn when the app is still ad-hoc signed.

## In Progress
- Waiting for manual local code-signing identity creation.

## Next
- User must run `./scripts/create-local-codesign-identity.sh`.
- Rebuild/reinstall with `./scripts/install-local.sh`.
- Grant Accessibility once for the newly signed app.
- Confirm `codesign -dv /Applications/SynonymPicker.app` is no longer `Signature=adhoc`.

## Blockers
- Creating a trusted local self-signed code-signing identity writes to the user's login keychain. The sandbox rejected doing this automatically; it must be run manually by the user.

## Verify Log
- 2026-06-04: `./scripts/verify.sh` passed with ad-hoc fallback.
- 2026-06-04: `./scripts/verify.sh` passed after build/install/signing script hardening.
