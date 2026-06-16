# Project Memory

## Purpose
- Изолированная память проекта Synonym Picker Mac.
- Этот project root не должен смешиваться с корневым workspace memory и задачами других проектов.

## Read Order for New Session
1. `memory/MEMORY.md`
2. `memory/active-task.md`
3. `memory/phase-status.md`
4. `memory/patterns-gotchas.md`
5. `memory/session-log.md`
6. `docs/tasks/INDEX.md`
7. `SPEC.md` активной задачи из `docs/tasks/active/`

## Current Snapshot
- Active phase: `M3 Local Model`.
- Active task: `SPM-019-stable-local-signing-identity`.
- Blocked task: `SPM-019-stable-local-signing-identity` (manual keychain/trust action).
- Last completed: `SPM-031-common-adjective-fast-coverage`.
- Process mode: spec-driven (`docs/tasks/backlog -> active -> done`).
- Source of truth: local `docs/`, `memory/`, and active task `SPEC.md`.
- Verification gate: lint + typecheck + tests before moving a task to done.
