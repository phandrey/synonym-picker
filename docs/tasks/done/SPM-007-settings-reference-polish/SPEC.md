# SPM-007 Settings Reference Polish

## Goal
Приблизить окно настроек к пользовательскому референсу по ощущению: более прозрачный dark material, компактная сетка, системная macOS-типографика, плотные отступы и простые rounded panels.

## Scope
- Сделать фон и панели визуально прозрачнее.
- Уменьшить визуальный вес карточек.
- Перестроить секции в compact grid с крупной SF Symbol и текстом.
- Сохранить базовую информацию Hotkey / Model / Permissions.
- Пересобрать `dist/SynonymPicker.app`.

## Out of Scope
- Hotkey logic.
- Model download.
- Accessibility permissions.
- Popup synonyms.
- Text replacement.
- Public `.zip`/`.dmg`.

## Acceptance Criteria
- Settings window remains readable.
- Settings window feels lighter/more transparent than previous version.
- Font and spacing are closer to the provided compact macOS utility reference.
- Verify gate passes.

## Verify Gate
```sh
./scripts/verify.sh
```

