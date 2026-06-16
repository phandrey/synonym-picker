import Foundation

struct SuggestionPopupPayload: Equatable, Sendable {
  let selectedText: String?
  let suggestions: [String]
  let title: String
  let message: String

  var hasSuggestions: Bool {
    !suggestions.isEmpty
  }

  static func suggestions(selectedText: String, suggestions: [String]) -> SuggestionPopupPayload {
    SuggestionPopupPayload(
      selectedText: selectedText,
      suggestions: suggestions,
      title: "Synonyms",
      message: "AI suggestions"
    )
  }

  static func selectionFailure(_ result: SelectionReadResult) -> SuggestionPopupPayload {
    SuggestionPopupPayload(
      selectedText: nil,
      suggestions: [],
      title: "No selection",
      message: result.message
    )
  }

  static func modelFailure(selectedText: String, message: String) -> SuggestionPopupPayload {
    SuggestionPopupPayload(
      selectedText: selectedText,
      suggestions: [],
      title: "Model not ready",
      message: message
    )
  }

  static func noUsableSuggestions(selectedText: String, message: String) -> SuggestionPopupPayload {
    SuggestionPopupPayload(
      selectedText: selectedText,
      suggestions: [],
      title: "No usable synonyms",
      message: message
    )
  }
}
