# SPM-002 Menu Bar App Scaffold

## Goal
Создать первый нативный macOS app scaffold: menu bar entry и окно настроек.

## Scope
- Создать macOS executable app target через Swift Package, потому что `xcodebuild` сейчас недоступен без полноценного Xcode.
- Добавить menu bar entry.
- Добавить окно настроек с разделами:
  - Hotkey
  - Model
  - Permissions
- Сделать базовый минималистичный полупрозрачный дизайн в духе Codex: quiet UI, vibrancy, аккуратные панели без визуального шума.
- Подключить существующий `SynonymPickerCore` как основу для будущей логики.
- Добавить script для сборки personal-install `.app` bundle в `dist/`.
- Обновить verify gate под app scaffold.

## Out of Scope
- Реальная регистрация global hotkey.
- Accessibility чтение/замена текста.
- Popup выбора синонимов.
- Скачивание модели.
- LLM inference.
- Публичный `.zip`/`.dmg` release для GitHub.

## Acceptance Criteria
- Приложение собирается как macOS executable target.
- Personal-install bundle создается в `dist/SynonymPicker.app`.
- Есть menu bar entry.
- Окно настроек открывается из menu bar.
- UI настроек содержит разделы Hotkey, Model, Permissions.
- Verify gate проходит.

## Verify Gate
```sh
./scripts/verify.sh
```
