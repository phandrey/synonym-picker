import ApplicationServices
import Foundation

@MainActor
enum AccessibilityPermissionService {
  static var isTrusted: Bool {
    AXIsProcessTrusted()
  }

  static func requestPrompt() {
    let options =
      [
        "AXTrustedCheckOptionPrompt": true
      ] as CFDictionary

    AXIsProcessTrustedWithOptions(options)
  }
}
