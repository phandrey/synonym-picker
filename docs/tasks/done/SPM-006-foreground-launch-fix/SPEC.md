# SPM-006 Foreground Launch Fix

## Goal
Сделать запуск приложения очевидным для personal MVP: после `open /Applications/SynonymPicker.app` приложение должно появляться как обычное foreground macOS app, окно настроек должно выходить вперед, status item должен оставаться видимым.

## Scope
- Убрать `LSUIElement` из `Info.plist`.
- Использовать regular activation policy.
- Явно выводить settings window вперед.
- Пересобрать `dist/SynonymPicker.app`.

## Out of Scope
- Hotkey logic.
- Model download.
- Accessibility permissions.
- Popup synonyms.
- Text replacement.
- Public `.zip`/`.dmg`.

## Acceptance Criteria
- App bundle builds.
- On launch, app can show Dock/process presence as a regular app.
- Settings window is explicitly made key/front.
- Existing status item remains available.
- Verify gate passes.

## Verify Gate
```sh
./scripts/verify.sh
```

