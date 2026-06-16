import SynonymPickerCore
import Testing

@Test func normalizeFiltersSourceWordDuplicatesAndEmptyValues() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: [" хороший ", "отличный", "отличный", "", "\"удачный\""],
    selectedWord: "хороший"
  )

  #expect(result == ["отличный", "удачный"])
}

@Test func normalizeRespectsLimit() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["one", "two", "three"],
    selectedWord: "source",
    limit: 2
  )

  #expect(result == ["one", "two"])
}

@Test func normalizeRejectsLongPhrases() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["very good option indeed", "strong"],
    selectedWord: "good"
  )

  #expect(result == ["strong"])
}

@Test func normalizeRejectsNearDuplicateRussianForms() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["смешный", "смешливая", "забавный", "комичный"],
    selectedWord: "смешной"
  )

  #expect(result == ["забавный", "комичный"])
}

@Test func normalizeRejectsInvalidLookingValues() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["тоскообразно", "грустно!", "печально", "sad://word", "уныло"],
    selectedWord: "грустно"
  )

  #expect(result == ["печально", "уныло"])
}

@Test func normalizeRankedSortsByScore() {
  let result = SynonymPostProcessor.normalizeRanked(
    rawCandidates: [
      RankedSynonymCandidate(word: "забавный", score: 72),
      RankedSynonymCandidate(word: "радостный", score: 44),
      RankedSynonymCandidate(word: "веселый", score: 95),
    ],
    selectedWord: "смешной"
  )

  #expect(result == ["веселый", "забавный", "радостный"])
}

@Test func normalizeRankedKeepsHighestScoredDuplicate() {
  let result = SynonymPostProcessor.normalizeRanked(
    rawCandidates: [
      RankedSynonymCandidate(word: " печальный ", score: 30),
      RankedSynonymCandidate(word: "унылый", score: 60),
      RankedSynonymCandidate(word: "печальный", score: 90),
    ],
    selectedWord: "грустный"
  )

  #expect(result == ["печальный", "унылый"])
}

@Test func normalizeTreatsYoAndYeAsSameWord() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["весёлый", "радостный", "забавный"],
    selectedWord: "веселый"
  )

  #expect(result == ["радостный", "забавный"])
}

@Test func normalizeRejectsWrongShapeForAdjective() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["нашёл", "взял", "забавный", "радостный"],
    selectedWord: "смешной"
  )

  #expect(result == ["забавный", "радостный"])
}

@Test func normalizeKeepsPluralAdjectiveForms() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["добротные", "привлекательные", "выдающийся", "приятный"],
    selectedWord: "классные"
  )

  #expect(result == ["добротные", "привлекательные", "приятные"])
}

@Test func normalizeKeepsInstrumentalAdjectiveForms() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["добротным", "прекрасным", "хорошим", "свежий"],
    selectedWord: "отличным"
  )

  #expect(result == ["добротным", "прекрасным", "хорошим", "свежим"])
}

@Test func normalizeAdaptsBaseAdjectivesToInstrumentalSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["аппетитный", "лакомый", "свежий", "вкусный"],
    selectedWord: "вкусным"
  )

  #expect(result == ["аппетитным", "лакомым", "свежим"])
}

@Test func normalizeAdaptsBaseAdjectivesToPluralSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["отличный", "добротный", "привлекательный", "классный"],
    selectedWord: "классные"
  )

  #expect(result == ["отличные", "добротные", "привлекательные"])
}

@Test func normalizeAdaptsVelarBaseAdjectivesToFeminineSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["мягкий", "строгий", "тихий"],
    selectedWord: "свежая"
  )

  #expect(result == ["мягкая", "строгая", "тихая"])
}

@Test func normalizeAdaptsVelarBaseAdjectivesToPluralSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["мягкий", "строгий", "тихий"],
    selectedWord: "свежие"
  )

  #expect(result == ["мягкие", "строгие", "тихие"])
}

@Test func normalizeRejectsInfinitivesForFiniteVerbSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["попробовать", "попытаемся", "проверим", "протестируем"],
    selectedWord: "попробуем"
  )

  #expect(result == ["попытаемся", "проверим", "протестируем"])
}

@Test func normalizeRejectsSameVerbLexemeVariants() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["переделывать", "переделать", "исправлял", "дорабатывал"],
    selectedWord: "переделывал"
  )

  #expect(result == ["исправлял", "дорабатывал"])
}

@Test func normalizeRejectsSameReflexiveVerbLexemeVariants() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["появляется", "отобразится", "возникнет"],
    selectedWord: "появится"
  )

  #expect(result == ["отобразится", "возникнет"])
}

@Test func normalizeRejectsAdjectivesForShortAdverbSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["быстрый", "мгновенно", "сразу", "оперативно"],
    selectedWord: "быстро"
  )

  #expect(result == ["мгновенно", "сразу", "оперативно"])
}

@Test func normalizeRejectsMixedScriptArtifactsForRussianSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["дramатично", "от缓和的", "значительно", "очень"],
    selectedWord: "сильно"
  )

  #expect(result == ["значительно", "очень"])
}

@Test func normalizeRejectsPhrasesForSingleWordSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["местные", "местные дела", "региональные"],
    selectedWord: "локальные"
  )

  #expect(result == ["местные", "региональные"])
}

@Test func normalizeAllowsShortPhrasesForAdverbSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["в порядке", "без проблем", "нормально"],
    selectedWord: "нормально"
  )

  #expect(result == ["в порядке", "без проблем"])
}

@Test func normalizeDoesNotTreatShortNounEndingWithImAsAdjective() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["настройка", "формат", "режим"],
    selectedWord: "режим"
  )

  #expect(result == ["настройка", "формат"])
}

@Test func normalizeDoesNotTreatOstNounAsInfinitive() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["темп", "быстрота", "скорость"],
    selectedWord: "скорость"
  )

  #expect(result == ["темп", "быстрота"])
}

@Test func normalizeKeepsManualAdverbAlternatives() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["самостоятельно", "руками", "вручную"],
    selectedWord: "вручную"
  )

  #expect(result == ["самостоятельно", "руками"])
}

@Test func normalizeDoesNotTreatRepositoryNounAsAdjective() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["проект", "каталог", "репозиторий"],
    selectedWord: "репозиторий"
  )

  #expect(result == ["проект", "каталог"])
}

@Test func normalizeKeepsDirectlyAdverbAlternatives() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["непосредственно", "прямо", "напрямую"],
    selectedWord: "напрямую"
  )

  #expect(result == ["непосредственно", "прямо"])
}

@Test func normalizeRejectsPhraseContainingSourceWord() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["мягко выделяющий", "плавно", "деликатно"],
    selectedWord: "мягко"
  )

  #expect(result == ["плавно", "деликатно"])
}

@Test func normalizeRejectsInfinitiveForNounSource() {
  let result = SynonymPostProcessor.normalize(
    rawSuggestions: ["подменить", "вариант", "замена"],
    selectedWord: "замена"
  )

  #expect(result == ["вариант"])
}
