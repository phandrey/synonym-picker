# Patterns and Gotchas

## Patterns
- Работать только внутри `synonym-picker-mac/`.
- Каждая задача имеет `SPEC.md` и, при выполнении, `STATUS.md`.
- Scope задачи не расширяется без явной причины.
- Перед переносом задачи в `done` обязательно выполнить verify gate: lint, typecheck, tests.

## Gotchas
- В корне workspace уже есть memory/docs/tasks другого проекта; их не использовать для Synonym Picker Mac.
- В workspace path есть `:`; не создавать виртуальные окружения или сторонние build caches в корне без необходимости.
- `xcodebuild` сейчас недоступен: установлены Command Line Tools, но не полноценный Xcode.
- Доступен Swift 6.1.2, поэтому текущий bootstrap использует Swift Package и `swift build`/`swift test`.
- `swiftlint` не установлен; lint gate использует `swift format lint`.
- Context7 tool недоступен в текущем окружении; документацию проверять через доступные локальные CLI help или официальные источники при разрешенном веб-доступе.

