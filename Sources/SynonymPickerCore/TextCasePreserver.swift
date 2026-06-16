import Foundation

public enum TextCasePreserver {
  public static func applyingCase(of original: String, to replacement: String) -> String {
    guard !original.isEmpty, !replacement.isEmpty else {
      return replacement
    }

    if original == original.uppercased() {
      return replacement.uppercased()
    }

    if isCapitalized(original) {
      return replacement.prefix(1).uppercased() + replacement.dropFirst()
    }

    return replacement
  }

  private static func isCapitalized(_ value: String) -> Bool {
    guard let first = value.first else {
      return false
    }

    let firstLetter = String(first)
    let rest = String(value.dropFirst())
    return firstLetter == firstLetter.uppercased() && rest == rest.lowercased()
  }
}
