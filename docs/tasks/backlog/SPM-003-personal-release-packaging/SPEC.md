# SPM-003 Personal Release Packaging

## Goal
Подготовить формат распространения, чтобы позже можно было выложить приложение на GitHub и дать людям скачать `.zip` или `.dmg`.

## Scope
- Сделать release `.zip` из `SynonymPicker.app`.
- Добавить `.dmg` сборку, если доступен подходящий локальный инструмент.
- Добавить README-инструкцию установки.
- Зафиксировать ограничения unsigned/not-notarized приложения.
- Подготовить структуру GitHub Releases.

## Out of Scope
- Apple Developer signing.
- Notarization.
- App Store distribution.
- Автоматический updater.

## Acceptance Criteria
- Есть reproducible command для `.zip`.
- Есть reproducible command для `.dmg` или явно зафиксирован blocker.
- README объясняет, как установить и какие macOS permissions нужны.
- Verify gate проходит.

## Verify Gate
```sh
./scripts/verify.sh
```

