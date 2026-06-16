import Foundation

public enum SynonymResponseParser {
  public static func parse(_ content: String) -> [RankedSynonymCandidate] {
    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

    if let parsed = parseJSON(trimmed) {
      return parsed
    }

    if let jsonRange = trimmed.range(of: #"\{[\s\S]*\}"#, options: .regularExpression) {
      let jsonCandidate = String(trimmed[jsonRange])
      if let parsed = parseJSON(jsonCandidate) {
        return parsed
      }
    }

    if let jsonRange = trimmed.range(of: #"\[[\s\S]*\]"#, options: .regularExpression) {
      let jsonCandidate = String(trimmed[jsonRange])
      if let parsed = parseJSON(jsonCandidate) {
        return parsed
      }
    }

    return parsePlainTextCandidates(trimmed)
      .map { RankedSynonymCandidate(word: $0) }
  }

  private static func parseJSON(_ value: String) -> [RankedSynonymCandidate]? {
    guard let data = value.data(using: .utf8) else {
      return nil
    }

    if let object = try? JSONDecoder().decode(CandidateListResponse.self, from: data),
      !object.candidates.isEmpty
    {
      return object.candidates
    }

    if let ranked = try? JSONDecoder().decode([RankedCandidateResponse].self, from: data) {
      let candidates: [RankedSynonymCandidate] = ranked.compactMap { candidate in
        guard let word = candidate.resolvedWord else {
          return nil
        }

        return RankedSynonymCandidate(word: word, score: candidate.score)
      }

      if !candidates.isEmpty {
        return candidates
      }
    }

    if let strings = try? JSONDecoder().decode([String].self, from: data) {
      return strings.map { RankedSynonymCandidate(word: $0) }
    }

    return nil
  }

  private static func parsePlainTextCandidates(_ value: String) -> [String] {
    value
      .split(whereSeparator: \.isNewline)
      .flatMap { line -> [String] in
        let cleaned = cleanPlainTextLine(String(line))
        guard !cleaned.isEmpty else {
          return []
        }

        let payload = payloadAfterLabel(in: cleaned)
        let separators = CharacterSet(charactersIn: ",;")
        let parts = payload.components(separatedBy: separators)

        if parts.count > 1 {
          return parts.map(cleanPlainTextLine).filter { !$0.isEmpty }
        }

        return [payload]
      }
  }

  private static func cleanPlainTextLine(_ value: String) -> String {
    value
      .replacingOccurrences(
        of: #"^\s*[-*\d.)]+\s*"#,
        with: "",
        options: .regularExpression
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .trimmingCharacters(in: CharacterSet(charactersIn: "\"'`.,;:[](){}"))
  }

  private static func payloadAfterLabel(in value: String) -> String {
    guard let delimiter = value.firstIndex(of: ":") else {
      return value
    }

    let label = value[..<delimiter].lowercased()
    let knownLabels = ["синонимы", "варианты", "замены", "synonyms", "variants", "replacements"]
    guard knownLabels.contains(where: { label.contains($0) }) else {
      return value
    }

    return cleanPlainTextLine(String(value[value.index(after: delimiter)...]))
  }
}

private struct CandidateListResponse: Decodable {
  let candidates: [RankedSynonymCandidate]

  enum CodingKeys: String, CodingKey, CaseIterable {
    case synonyms
    case variants
    case replacements
    case russianSynonyms = "синонимы"
    case russianVariants = "варианты"
    case russianReplacements = "замены"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    for key in CodingKeys.allCases {
      if let payload = try? container.decode([CandidatePayload].self, forKey: key) {
        candidates = payload.compactMap(\.candidate)
        return
      }
    }

    candidates = []
  }
}

private enum CandidatePayload: Decodable {
  case string(String)
  case ranked(RankedCandidateResponse)

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let value = try? container.decode(String.self) {
      self = .string(value)
      return
    }

    self = .ranked(try container.decode(RankedCandidateResponse.self))
  }

  var candidate: RankedSynonymCandidate? {
    switch self {
    case .string(let value):
      return RankedSynonymCandidate(word: value)
    case .ranked(let value):
      guard let word = value.resolvedWord else {
        return nil
      }

      return RankedSynonymCandidate(word: word, score: value.score)
    }
  }
}

private struct RankedCandidateResponse: Decodable {
  let word: String?
  let synonym: String?
  let variant: String?
  let replacement: String?
  let russianWord: String?
  let russianSynonym: String?
  let russianReplacement: String?
  let score: Double?

  enum CodingKeys: String, CodingKey {
    case word
    case synonym
    case variant
    case replacement
    case russianWord = "слово"
    case russianSynonym = "синоним"
    case russianReplacement = "замена"
    case score
  }

  var resolvedWord: String? {
    word ?? synonym ?? variant ?? replacement ?? russianWord ?? russianSynonym ?? russianReplacement
  }
}
