# SPM-008 Hotkey Selection Mock Flow

## Goal
Добавить первый проверяемый core UX: пользователь назначает global hotkey в settings, приложение сохраняет его, регистрирует системный hotkey и по нажатию показывает mock-список синонимов.

## Scope
- Сделать Hotkey tile интерактивной.
- Реализовать режим записи хоткея в окне настроек.
- Сохранять выбранный hotkey в `UserDefaults`.
- Регистрировать global hotkey через нативный macOS/Carbon API.
- Показывать компактное mock-окно с 5 тестовыми синонимами при нажатии hotkey.
- Пересобрать `dist/SynonymPicker.app`.

## Out of Scope
- Чтение выделенного слова.
- Контекст текста.
- Настоящий popup chooser рядом с текстом.
- Навигация стрелками / Enter / click в suggestions.
- Замена текста.
- Model download.
- LLM inference.

## Acceptance Criteria
- В settings можно начать запись hotkey.
- Нажатое сочетание отображается в Hotkey tile.
- Hotkey сохраняется между запусками.
- Нажатие hotkey показывает mock suggestions window.
- Verify gate проходит.

## Verify Gate
```sh
./scripts/verify.sh
```

