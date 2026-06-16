# SPM-004 Settings UI Polish

## Goal
Уменьшить окно настроек и сделать визуальный стиль легче: более прозрачный material, меньше визуального веса, стандартная macOS system typography.

## Scope
- Уменьшить ширину и внутренние отступы окна настроек.
- Сделать карточки и status chips более прозрачными.
- Уменьшить крупность заголовков и иконок.
- Использовать стандартные SwiftUI/macOS text styles вместо тяжелых кастомных весов.
- Собрать новый `dist/SynonymPicker.app`.

## Out of Scope
- Hotkey logic.
- Model download.
- Accessibility permissions.
- Popup synonyms.
- Text replacement.
- Public `.zip`/`.dmg`.

## Acceptance Criteria
- Settings window visually smaller than previous version.
- UI remains readable.
- Typography is based on default macOS/SwiftUI text styles.
- Verify gate passes.

## Verify Gate
```sh
./scripts/verify.sh
```

