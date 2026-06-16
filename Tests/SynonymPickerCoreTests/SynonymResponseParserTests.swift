import SynonymPickerCore
import Testing

@Test func responseParserReadsStringArray() {
  let result = SynonymResponseParser.parse(#"["радостный","забавный"]"#)

  #expect(result.map(\.word) == ["радостный", "забавный"])
}

@Test func responseParserReadsSynonymsObjectStringArray() {
  let result = SynonymResponseParser.parse(#"{"synonyms":["попытаемся","проверим"]}"#)

  #expect(result.map(\.word) == ["попытаемся", "проверим"])
}

@Test func responseParserExtractsSynonymsObjectFromMarkdown() {
  let result = SynonymResponseParser.parse(
    """
    ```json
    {"synonyms":["обычные","типовые"]}
    ```
    """
  )

  #expect(result.map(\.word) == ["обычные", "типовые"])
}

@Test func responseParserReadsSynonymsObjectRankedArray() {
  let result = SynonymResponseParser.parse(
    #"{"synonyms":[{"word":"исправлял","score":91},{"замена":"дорабатывал","score":72}]}"#
  )

  #expect(result.map(\.word) == ["исправлял", "дорабатывал"])
  #expect(result.map(\.score) == [91, 72])
}

@Test func responseParserReadsRankedObjectAliases() {
  let result = SynonymResponseParser.parse(
    #"[{"variant":"радостный","score":91},{"замена":"забавный","score":72}]"#
  )

  #expect(result.map(\.word) == ["радостный", "забавный"])
  #expect(result.map(\.score) == [91, 72])
}

@Test func responseParserFallsBackToStringArrayForUnknownObjects() {
  let result = SynonymResponseParser.parse(#"["счастливый","жизнерадостный"]"#)

  #expect(result.map(\.word) == ["счастливый", "жизнерадостный"])
}

@Test func responseParserExtractsJsonArrayFromText() {
  let result = SynonymResponseParser.parse(
    """
    ```json
    ["отличный","добротный"]
    ```
    """
  )

  #expect(result.map(\.word) == ["отличный", "добротный"])
}

@Test func responseParserSplitsCommaSeparatedPlainText() {
  let result = SynonymResponseParser.parse("местные, региональные, внутренние")

  #expect(result.map(\.word) == ["местные", "региональные", "внутренние"])
}

@Test func responseParserSplitsLabeledCommaSeparatedPlainText() {
  let result = SynonymResponseParser.parse("Синонимы: обычные, типовые, шаблонные")

  #expect(result.map(\.word) == ["обычные", "типовые", "шаблонные"])
}
