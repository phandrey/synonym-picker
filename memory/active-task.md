# Active Task

- Task ID: `SPM-038-public-github-release-prep`
- SPEC: `docs/tasks/active/SPM-038-public-github-release-prep/SPEC.md`
- Current focus: implemented and installed; ready for GitHub source handoff, with fullscreen overlay hotfix applied.
- Last validation: `./scripts/verify.sh` passed with 45 tests after fullscreen hotfix; `/Applications/SynonymPicker.app` installed and opened.
- Model benchmark note: several 50-case public benchmark passes were used for fixes, but the final heavy run was stopped by user request to reduce local resource usage.
- Previous active task: `SPM-037-status-menu-controls`
- Related active task: `SPM-019-stable-local-signing-identity`
- Note: `SPM-019-stable-local-signing-identity` remains externally blocked on manual keychain/trust setup; installed bundle is still ad-hoc signed.
- Last completed: `SPM-036-fullscreen-overlay-clickaway-quality-audit` (user-confirmed working)
