import Foundation

public enum HotkeyModifier: String, Codable, Hashable, Sendable {
  case command
  case control
  case option
  case shift
}

public struct Hotkey: Codable, Equatable, Sendable {
  public let key: String
  public let modifiers: Set<HotkeyModifier>

  public init(key: String, modifiers: Set<HotkeyModifier>) {
    self.key = key
    self.modifiers = modifiers
  }
}
