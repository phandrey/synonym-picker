import Foundation

public struct RankedSynonymCandidate: Equatable, Sendable {
  public let word: String
  public let score: Double?

  public init(word: String, score: Double? = nil) {
    self.word = word
    self.score = score
  }
}

public enum SynonymPostProcessor {
  public static func normalize(
    rawSuggestions: [String],
    selectedWord: String,
    limit: Int = 8
  ) -> [String] {
    normalizeRanked(
      rawCandidates: rawSuggestions.map { RankedSynonymCandidate(word: $0) },
      selectedWord: selectedWord,
      limit: limit
    )
  }

  public static func normalizeRanked(
    rawCandidates: [RankedSynonymCandidate],
    selectedWord: String,
    limit: Int = 8
  ) -> [String] {
    let source = selectedWord.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !source.isEmpty, limit > 0 else {
      return []
    }

    var candidatesByKey: [String: ProcessedCandidate] = [:]
    var nextOrder = 0

    for candidate in rawCandidates {
      let normalized = adaptGrammaticalShape(
        clean(candidate.word),
        source: source
      )
      guard isUsable(normalized, source: source) else {
        continue
      }

      let key = comparisonKey(normalized)
      let processed = ProcessedCandidate(
        word: normalized,
        score: candidate.score,
        order: nextOrder
      )
      nextOrder += 1

      if let existing = candidatesByKey[key] {
        if processed.sortKey > existing.sortKey {
          candidatesByKey[key] = processed
        }
      } else {
        candidatesByKey[key] = processed
      }
    }

    return candidatesByKey.values
      .sorted { left, right in
        if left.sortKey == right.sortKey {
          return left.order < right.order
        }

        return left.sortKey > right.sortKey
      }
      .prefix(limit)
      .map(\.word)
  }

  private static func clean(_ value: String) -> String {
    value
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .trimmingCharacters(in: CharacterSet(charactersIn: "\"'`.,;:[](){}"))
  }

  private static func isUsable(_ value: String, source: String) -> Bool {
    guard !value.isEmpty else {
      return false
    }

    guard comparisonKey(value) != comparisonKey(source) else {
      return false
    }

    guard looksLikeWordOrShortPhrase(value) else {
      return false
    }

    guard respectsSourceWordCount(value, source: source) else {
      return false
    }

    guard !looksLikeGeneratedArtifact(value, source: source) else {
      return false
    }

    guard !containsSourceWord(value, source: source) else {
      return false
    }

    guard usesCompatibleScript(value, source: source) else {
      return false
    }

    guard !isNearDuplicate(value, source: source) else {
      return false
    }

    guard isGrammaticallyCompatible(value, source: source) else {
      return false
    }

    let parts = value.split(whereSeparator: { $0.isWhitespace })
    return parts.count <= 3
  }

  private static func respectsSourceWordCount(_ value: String, source: String) -> Bool {
    let sourceParts = source.split(whereSeparator: { $0.isWhitespace })
    let valueParts = value.split(whereSeparator: { $0.isWhitespace })

    guard sourceParts.count == 1 else {
      return valueParts.count <= 3
    }

    if isLikelyShortAdverb(source) {
      return valueParts.count <= 3
    }

    return valueParts.count == 1
  }

  private static func looksLikeWordOrShortPhrase(_ value: String) -> Bool {
    value.unicodeScalars.allSatisfy { scalar in
      CharacterSet.letters.contains(scalar)
        || CharacterSet.whitespaces.contains(scalar)
        || scalar == "-"
    }
  }

  private static func looksLikeGeneratedArtifact(_ value: String, source: String) -> Bool {
    let lowercased = value.lowercased()
    let lowercasedSource = source.lowercased()

    return lowercased.hasSuffix("образно") && !lowercasedSource.hasSuffix("образно")
  }

  private static func containsSourceWord(_ value: String, source: String) -> Bool {
    let sourceKey = comparisonKey(source)
    guard !sourceKey.isEmpty else {
      return false
    }

    return comparisonKey(value)
      .split(whereSeparator: { !$0.isLetter })
      .contains { $0 == sourceKey }
  }

  private static func usesCompatibleScript(_ value: String, source: String) -> Bool {
    guard containsCyrillic(source) else {
      return true
    }

    return !containsLatin(value) && !containsCJK(value)
  }

  private static func isNearDuplicate(_ value: String, source: String) -> Bool {
    if let valueStem = verbLexemeStem(value),
      let sourceStem = verbLexemeStem(source),
      valueStem.count >= 4,
      sourceStem.count >= 4,
      valueStem == sourceStem
    {
      return true
    }

    let normalizedValue = stemCandidate(value)
    let normalizedSource = stemCandidate(source)

    guard normalizedValue.count >= 5, normalizedSource.count >= 5 else {
      return false
    }

    return normalizedValue.hasPrefix(normalizedSource)
      || normalizedSource.hasPrefix(normalizedValue)
  }

  private static func stemCandidate(_ value: String) -> String {
    let lowercased = comparisonKey(value)
    let firstWord =
      lowercased
      .split(whereSeparator: { !$0.isLetter })
      .first
      .map(String.init) ?? lowercased

    return stripCommonRussianSuffix(from: firstWord)
  }

  private static func comparisonKey(_ value: String) -> String {
    value.lowercased().replacingOccurrences(of: "ё", with: "е")
  }

  private static func containsCyrillic(_ value: String) -> Bool {
    value.unicodeScalars.contains { scalar in
      (0x0400...0x052F).contains(Int(scalar.value))
    }
  }

  private static func containsLatin(_ value: String) -> Bool {
    value.unicodeScalars.contains { scalar in
      (0x0041...0x005A).contains(Int(scalar.value))
        || (0x0061...0x007A).contains(Int(scalar.value))
    }
  }

  private static func containsCJK(_ value: String) -> Bool {
    value.unicodeScalars.contains { scalar in
      (0x3400...0x9FFF).contains(Int(scalar.value))
    }
  }

  private static func isGrammaticallyCompatible(_ value: String, source: String) -> Bool {
    if let sourceVerbShape = strongVerbShape(for: source) {
      return verbShape(for: value) == sourceVerbShape
    }

    if isLikelyShortAdverb(source) {
      return !looksLikeAdjective(firstWord(value))
    }

    guard let sourceEndingGroup = adjectiveEndingGroup(for: source) else {
      if let sourceVerbShape = verbShape(for: source) {
        return verbShape(for: value) == sourceVerbShape
      }

      return verbShape(for: value) == nil
    }

    let firstValueWord = firstWord(value)
    guard !firstValueWord.isEmpty else {
      return false
    }

    return sourceEndingGroup.contains { firstValueWord.hasSuffix($0) }
  }

  private static func strongVerbShape(for value: String) -> VerbShape? {
    let word = firstWord(value)
    guard word.count >= 4 else {
      return nil
    }

    if word.hasSuffix("ость") {
      return nil
    }

    if word.hasSuffix("ться")
      || word.hasSuffix("тись")
      || word.hasSuffix("ть")
      || word.hasSuffix("ти")
      || word.hasSuffix("чь")
    {
      return .infinitive
    }

    if word.hasSuffix("лись") {
      return .pastPlural
    }

    if word.hasSuffix("лась") {
      return .pastFeminine
    }

    if word.hasSuffix("лся") {
      return .pastMasculine
    }

    if ["ывали", "ивали", "али", "яли", "или", "ели"].contains(where: word.hasSuffix) {
      return .pastPlural
    }

    if ["ится", "ется", "утся", "ются"].contains(where: word.hasSuffix)
      || (word.hasSuffix("нет") && word.count >= 7)
    {
      return .finite
    }

    if ["ывала", "ивала", "ала", "яла", "ила", "ела"].contains(where: word.hasSuffix) {
      return .pastFeminine
    }

    if ["ывал", "ивал", "ал", "ял", "ил", "ел"].contains(where: word.hasSuffix) {
      return .pastMasculine
    }

    if [
      "уемся", "аемся", "яемся", "емся", "имся",
      "ируем", "уем", "аем", "яем", "еем",
    ].contains(where: word.hasSuffix) {
      return .firstPersonPlural
    }

    return nil
  }

  private static func verbShape(for value: String) -> VerbShape? {
    if let shape = strongVerbShape(for: value) {
      return shape
    }

    let word = firstWord(value)
    guard word.count >= 6 else {
      return nil
    }

    if ["ем", "ём", "им"].contains(where: word.hasSuffix) {
      return .firstPersonPlural
    }

    return nil
  }

  private static func verbLexemeStem(_ value: String) -> String? {
    var word = firstWord(value)
    guard word.count >= 5 else {
      return nil
    }

    if word.hasSuffix("ся") || word.hasSuffix("сь") {
      word = String(word.dropLast(2))
    }

    let suffixes = [
      "ываться", "иваться", "ывались", "ивались", "ывалась", "ивалась", "ывался", "ивался",
      "ывать", "ивать", "овать", "евать", "ались", "ялись", "ились", "елись", "алась",
      "ялась", "илась", "елась", "ался", "ялся", "ился", "елся", "аем", "яем", "еем",
      "уем", "ает", "яет", "еет", "ует", "ит", "ет", "ут", "ют", "ывали", "ивали",
      "ала", "яла", "ила", "ела", "али", "яли", "или", "ели", "ать", "ять", "еть", "ить",
      "уть", "ться", "тись", "ывал", "ивал", "ал", "ял", "ил", "ел", "ем", "ём", "им", "ти",
      "ть",
    ]

    for suffix in suffixes where word.hasSuffix(suffix) && word.count - suffix.count >= 4 {
      return canonicalVerbStem(String(word.dropLast(suffix.count)))
    }

    return nil
  }

  private static func canonicalVerbStem(_ value: String) -> String {
    if value.hasSuffix("л"), value.count >= 5 {
      return String(value.dropLast())
    }

    return value
  }

  private static func adaptGrammaticalShape(_ value: String, source: String) -> String {
    guard !value.contains(" "),
      let sourceEndingGroup = adjectiveEndingGroup(for: source),
      !sourceEndingGroup.isNominativeMasculine,
      let adjectiveBase = adjectiveBase(for: value)
    else {
      return value
    }

    return adjectiveBase.stem + sourceEndingGroup.ending(for: adjectiveBase.style)
  }

  private static func adjectiveBase(for value: String) -> AdjectiveBase? {
    let word = firstWord(value)
    if word.hasSuffix("ий") {
      let stem = String(word.dropLast("ий".count))
      if ["г", "к", "х"].contains(where: { stem.hasSuffix($0) }) && stem.count >= 3 {
        return AdjectiveBase(stem: stem, style: .velar)
      }
    }

    let forms: [(suffix: String, style: AdjectiveStyle)] = [
      ("ий", .soft),
      ("ый", .hard),
      ("ой", .hard),
    ]

    for form in forms where word.hasSuffix(form.suffix) && word.count - form.suffix.count >= 3 {
      return AdjectiveBase(
        stem: String(word.dropLast(form.suffix.count)),
        style: form.style
      )
    }

    return nil
  }

  private static func firstWord(_ value: String) -> String {
    let key = comparisonKey(value)
    let word =
      key
      .split(whereSeparator: { !$0.isLetter })
      .first
      .map(String.init)

    return word ?? key
  }

  private static func adjectiveEndingGroup(for value: String) -> AdjectiveEndingGroup? {
    let word = firstWord(value)
    if knownAdverbWords.contains(word) {
      return nil
    }
    if knownNonAdjectiveNounSuffixes.contains(where: word.hasSuffix) {
      return nil
    }

    return adjectiveEndingGroups.first { group in
      group.contains { ending in
        word.hasSuffix(ending) && hasPlausibleAdjectiveStem(word: word, ending: ending)
      }
    }
  }

  private static func hasPlausibleAdjectiveStem(word: String, ending: String) -> Bool {
    let stemLength = word.count - ending.count
    if ["ым", "им", "ом", "ем"].contains(ending) {
      return stemLength >= 4
    }

    return stemLength >= 3
  }

  private static func isLikelyShortAdverb(_ value: String) -> Bool {
    let word = firstWord(value)
    if knownAdverbWords.contains(word) {
      return true
    }

    guard word.count >= 4 else {
      return false
    }

    if adjectiveEndingGroup(for: word) != nil {
      return false
    }

    return word.hasSuffix("о") || word.hasSuffix("е")
  }

  private static func looksLikeAdjective(_ value: String) -> Bool {
    adjectiveEndingGroup(for: value) != nil
  }

  private static func stripCommonRussianSuffix(from value: String) -> String {
    let suffixes = [
      "иями", "ями", "ого", "ему", "ыми", "ими", "ыми", "ая", "яя", "ое", "ее", "ий", "ый",
      "ой", "ую", "юю", "ая", "яя", "ым", "им", "ом", "ем", "ых", "их", "ые", "ие", "о",
      "е", "а", "я", "ы", "и",
    ]

    for suffix in suffixes where value.hasSuffix(suffix) && value.count - suffix.count >= 4 {
      return String(value.dropLast(suffix.count))
    }

    return value
  }
}

private enum AdjectiveStyle {
  case hard
  case soft
  case velar
}

private enum VerbShape {
  case infinitive
  case pastMasculine
  case pastFeminine
  case pastPlural
  case firstPersonPlural
  case finite
}

private struct AdjectiveBase {
  let stem: String
  let style: AdjectiveStyle
}

private struct AdjectiveEndingGroup {
  let endings: [String]
  let hardEnding: String
  let softEnding: String
  let velarEnding: String
  let isNominativeMasculine: Bool

  init(
    endings: [String],
    hardEnding: String,
    softEnding: String,
    velarEnding: String? = nil,
    isNominativeMasculine: Bool = false
  ) {
    self.endings = endings
    self.hardEnding = hardEnding
    self.softEnding = softEnding
    self.velarEnding = velarEnding ?? hardEnding
    self.isNominativeMasculine = isNominativeMasculine
  }

  func contains(where predicate: (String) -> Bool) -> Bool {
    endings.contains(where: predicate)
  }

  func ending(for style: AdjectiveStyle) -> String {
    switch style {
    case .hard:
      hardEnding
    case .soft:
      softEnding
    case .velar:
      velarEnding
    }
  }
}

private let adjectiveEndingGroups = [
  AdjectiveEndingGroup(
    endings: ["ый", "ий", "ой"],
    hardEnding: "ый",
    softEnding: "ий",
    velarEnding: "ий",
    isNominativeMasculine: true
  ),
  AdjectiveEndingGroup(endings: ["ая", "яя"], hardEnding: "ая", softEnding: "яя"),
  AdjectiveEndingGroup(endings: ["ое", "ее"], hardEnding: "ое", softEnding: "ее"),
  AdjectiveEndingGroup(
    endings: ["ые", "ие"],
    hardEnding: "ые",
    softEnding: "ие",
    velarEnding: "ие"
  ),
  AdjectiveEndingGroup(endings: ["ого", "его"], hardEnding: "ого", softEnding: "его"),
  AdjectiveEndingGroup(endings: ["ому", "ему"], hardEnding: "ому", softEnding: "ему"),
  AdjectiveEndingGroup(
    endings: ["ым", "им"],
    hardEnding: "ым",
    softEnding: "им",
    velarEnding: "им"
  ),
  AdjectiveEndingGroup(endings: ["ом", "ем"], hardEnding: "ом", softEnding: "ем"),
  AdjectiveEndingGroup(
    endings: ["ых", "их"],
    hardEnding: "ых",
    softEnding: "их",
    velarEnding: "их"
  ),
  AdjectiveEndingGroup(endings: ["ую", "юю"], hardEnding: "ую", softEnding: "юю"),
  AdjectiveEndingGroup(
    endings: ["ыми", "ими"],
    hardEnding: "ыми",
    softEnding: "ими",
    velarEnding: "ими"
  ),
]

private let knownAdverbWords: Set<String> = [
  "вручную",
  "напрямую",
]

private let knownNonAdjectiveNounSuffixes = [
  "арий",
  "ерий",
  "орий",
  "торий",
]

private struct ProcessedCandidate {
  let word: String
  let score: Double?
  let order: Int

  var sortKey: Double {
    score ?? Double(-order)
  }
}
