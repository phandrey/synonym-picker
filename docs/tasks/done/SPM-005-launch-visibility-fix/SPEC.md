# SPM-005 Launch Visibility Fix

## Goal
Сделать локальный запуск приложения очевидным: после `open /Applications/SynonymPicker.app` пользователь должен увидеть окно настроек, а menu bar item должен быть заметен.

## Scope
- Автоматически открывать Settings window при запуске приложения.
- Сделать menu bar item видимым не только иконкой, но и коротким текстом.
- Собрать новый `dist/SynonymPicker.app`.

## Out of Scope
- Hotkey logic.
- Model download.
- Accessibility permissions.
- Popup synonyms.
- Text replacement.
- Public `.zip`/`.dmg`.

## Acceptance Criteria
- On launch, settings window is shown automatically.
- Menu bar item includes visible text.
- Existing Settings menu still opens the settings window.
- Verify gate passes.

## Verify Gate
```sh
./scripts/verify.sh
```

