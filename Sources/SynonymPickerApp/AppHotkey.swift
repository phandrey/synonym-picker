import AppKit
import Carbon
import Foundation

struct AppHotkey: Codable, Equatable {
  let keyCode: UInt32
  let modifierFlagsRawValue: UInt
  let keyName: String

  var displayTitle: String {
    "\(modifierSymbols)\(KeyNameResolver.displayName(forKeyCode: UInt16(keyCode)) ?? keyName)"
  }

  var carbonModifiers: UInt32 {
    let flags = NSEvent.ModifierFlags(rawValue: modifierFlagsRawValue)
    var result: UInt32 = 0

    if flags.contains(.command) {
      result |= UInt32(cmdKey)
    }
    if flags.contains(.control) {
      result |= UInt32(controlKey)
    }
    if flags.contains(.option) {
      result |= UInt32(optionKey)
    }
    if flags.contains(.shift) {
      result |= UInt32(shiftKey)
    }

    return result
  }

  static func from(event: NSEvent) -> AppHotkey? {
    let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let acceptedModifiers = NSEvent.ModifierFlags(
      rawValue: modifiers.rawValue & acceptedMask.rawValue)

    guard !acceptedModifiers.isEmpty else {
      return nil
    }

    guard let keyName = KeyNameResolver.displayName(forKeyCode: event.keyCode),
      !keyName.isEmpty
    else {
      return nil
    }

    return AppHotkey(
      keyCode: UInt32(event.keyCode),
      modifierFlagsRawValue: acceptedModifiers.rawValue,
      keyName: keyName
    )
  }

  private var modifierSymbols: String {
    let flags = NSEvent.ModifierFlags(rawValue: modifierFlagsRawValue)
    var symbols = ""

    if flags.contains(.control) {
      symbols += "⌃"
    }
    if flags.contains(.option) {
      symbols += "⌥"
    }
    if flags.contains(.shift) {
      symbols += "⇧"
    }
    if flags.contains(.command) {
      symbols += "⌘"
    }

    return symbols
  }

  private static let acceptedMask = NSEvent.ModifierFlags([
    .command, .control, .option, .shift,
  ])
}

private enum KeyNameResolver {
  static func displayName(forKeyCode keyCode: UInt16) -> String? {
    keyNames[keyCode]
  }

  private static let keyNames: [UInt16: String] = [
    0: "A",
    1: "S",
    2: "D",
    3: "F",
    4: "H",
    5: "G",
    6: "Z",
    7: "X",
    8: "C",
    9: "V",
    11: "B",
    12: "Q",
    13: "W",
    14: "E",
    15: "R",
    16: "Y",
    17: "T",
    18: "1",
    19: "2",
    20: "3",
    21: "4",
    22: "6",
    23: "5",
    24: "=",
    25: "9",
    26: "7",
    27: "-",
    28: "8",
    29: "0",
    30: "]",
    31: "O",
    32: "U",
    33: "[",
    34: "I",
    35: "P",
    36: "↩",
    37: "L",
    38: "J",
    39: "'",
    40: "K",
    41: ";",
    42: "\\",
    43: ",",
    44: "/",
    45: "N",
    46: "M",
    47: ".",
    48: "⇥",
    49: "Space",
    50: "`",
    51: "⌫",
    53: "Esc",
    76: "↩",
    123: "←",
    124: "→",
    125: "↓",
    126: "↑",
  ]
}
