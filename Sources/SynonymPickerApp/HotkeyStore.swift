import Foundation

enum HotkeyStore {
  private static let key = "selectedHotkey"

  static func load() -> AppHotkey? {
    guard let data = UserDefaults.standard.data(forKey: key) else {
      return nil
    }

    return try? JSONDecoder().decode(AppHotkey.self, from: data)
  }

  static func save(_ hotkey: AppHotkey) {
    guard let data = try? JSONEncoder().encode(hotkey) else {
      return
    }

    UserDefaults.standard.set(data, forKey: key)
  }
}
