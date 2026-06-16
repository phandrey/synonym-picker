# SPM-001 Project Bootstrap

## Goal
Создать изолированную папку проекта Synonym Picker Mac и подготовить spec-driven основу, в которой дальше можно безопасно реализовывать macOS-приложение, не трогая другие проекты в workspace.

## Scope
- Создать project root `synonym-picker-mac/`.
- Создать локальные `memory/` файлы проекта.
- Создать локальный `docs/tasks/` board.
- Создать активную задачу `SPM-001-project-bootstrap`.
- Создать backlog-задачу для следующего шага: menu bar app scaffold.
- Создать минимальный Swift Package с core target и тестами.
- Добавить verify script с lint/typecheck/tests.

## Out of Scope
- Нативный menu bar UI.
- Global hotkey.
- Accessibility API.
- Popup-список синонимов.
- Скачивание модели.
- Локальный LLM inference.
- Git commit/push.

## Deliverables
- `README.md`
- `Package.swift`
- `Sources/SynonymPickerCore/`
- `Tests/SynonymPickerCoreTests/`
- `scripts/verify.sh`
- `memory/*.md`
- `docs/tasks/INDEX.md`
- `docs/tasks/active/SPM-001-project-bootstrap/SPEC.md`
- `docs/tasks/active/SPM-001-project-bootstrap/STATUS.md`
- `docs/tasks/backlog/SPM-002-menu-bar-app-scaffold/SPEC.md`

## Acceptance Criteria
- Все deliverables существуют внутри `synonym-picker-mac/`.
- Корневые задачи и memory другого проекта не изменяются в рамках этой задачи.
- Swift Package собирается.
- Тесты проходят.
- Lint gate проходит через `swift format lint`.

## Verify Gate
```sh
./scripts/verify.sh
```

## Done Rule
Если verify gate проходит, обновить `STATUS.md`, `memory/*`, `docs/tasks/INDEX.md` и перенести задачу из `docs/tasks/active/` в `docs/tasks/done/`.

Если verify gate не проходит, не переносить задачу в done; зафиксировать blocker в `STATUS.md` и `memory/session-log.md`.

