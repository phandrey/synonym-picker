import Foundation

public struct TextContext: Equatable, Sendable {
  public let text: String
  public let selectedSentence: String?

  public init(text: String, selectedSentence: String? = nil) {
    self.text = text
    self.selectedSentence = selectedSentence
  }
}

public enum TextContextExtractor {
  public static func context(
    in fullText: String,
    selectedRange: NSRange,
    maxCharacters: Int = 420
  ) -> TextContext? {
    let trimmedFullText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedFullText.isEmpty, selectedRange.location != NSNotFound else {
      return nil
    }

    let nsText = fullText as NSString
    guard selectedRange.location >= 0,
      selectedRange.location <= nsText.length,
      selectedRange.location + selectedRange.length <= nsText.length
    else {
      return nil
    }

    let rawWindow = contextWindow(
      in: fullText,
      selectedRange: selectedRange,
      maxCharacters: maxCharacters
    )
    let normalized = normalizeWhitespace(rawWindow)
    let normalizedSentence = normalizeWhitespace(
      selectedSentence(
        in: fullText,
        selectedRange: selectedRange
      )
    )

    guard !normalized.isEmpty else {
      return nil
    }

    return TextContext(
      text: normalized,
      selectedSentence: normalizedSentence.isEmpty ? nil : normalizedSentence
    )
  }

  private static func contextWindow(
    in fullText: String,
    selectedRange: NSRange,
    maxCharacters: Int
  ) -> String {
    let nsText = fullText as NSString
    guard nsText.length > maxCharacters else {
      return fullText
    }

    let halfWindow = max(maxCharacters / 2, 80)
    let lowerBound = max(0, selectedRange.location - halfWindow)
    let upperBound = min(
      nsText.length,
      selectedRange.location + selectedRange.length + halfWindow
    )

    let sentenceStart = nearestSentenceStart(
      in: nsText,
      from: lowerBound,
      before: selectedRange.location
    )
    let sentenceEnd = nearestSentenceEnd(
      in: nsText,
      from: upperBound,
      after: selectedRange.location + selectedRange.length
    )

    return nsText.substring(
      with: NSRange(location: sentenceStart, length: sentenceEnd - sentenceStart)
    )
  }

  private static func nearestSentenceStart(
    in text: NSString,
    from lowerBound: Int,
    before selectedStart: Int
  ) -> Int {
    guard selectedStart > 0 else {
      return 0
    }

    var index = selectedStart - 1
    while index >= lowerBound {
      let character = UnicodeScalar(text.character(at: index))
      if let character, isSentenceBoundary(character) {
        return min(index + 1, text.length)
      }
      index -= 1
    }

    return lowerBound
  }

  private static func selectedSentence(
    in fullText: String,
    selectedRange: NSRange
  ) -> String {
    let nsText = fullText as NSString
    let sentenceStart = nearestSentenceStart(
      in: nsText,
      from: 0,
      before: selectedRange.location
    )
    let sentenceEnd = nearestSentenceEnd(
      in: nsText,
      from: nsText.length,
      after: selectedRange.location + selectedRange.length
    )

    return nsText.substring(
      with: NSRange(location: sentenceStart, length: sentenceEnd - sentenceStart)
    )
  }

  private static func nearestSentenceEnd(
    in text: NSString,
    from upperBound: Int,
    after selectedEnd: Int
  ) -> Int {
    guard selectedEnd < text.length else {
      return text.length
    }

    var index = selectedEnd
    while index < upperBound {
      let character = UnicodeScalar(text.character(at: index))
      if let character, isSentenceBoundary(character) {
        return min(index + 1, text.length)
      }
      index += 1
    }

    return upperBound
  }

  private static func isSentenceBoundary(_ scalar: UnicodeScalar) -> Bool {
    scalar == "." || scalar == "!" || scalar == "?" || scalar == "…" || scalar == "\n"
  }

  private static func normalizeWhitespace(_ value: String) -> String {
    value
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
