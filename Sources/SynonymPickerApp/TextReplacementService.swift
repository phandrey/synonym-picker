import AppKit
import CoreGraphics

@MainActor
final class TextReplacementService {
  private let pasteboard: NSPasteboard

  init(pasteboard: NSPasteboard = .general) {
    self.pasteboard = pasteboard
  }

  func replaceSelection(with replacement: String, in application: NSRunningApplication?) {
    let snapshot = PasteboardSnapshot.capture(from: pasteboard)

    pasteboard.clearContents()
    pasteboard.setString(replacement, forType: .string)

    application?.activate(options: [.activateAllWindows])

    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 120_000_000)
      postPasteShortcut()

      try? await Task.sleep(nanoseconds: 250_000_000)
      snapshot.restore(to: pasteboard)
    }
  }

  private func postPasteShortcut() {
    let source = CGEventSource(stateID: .hidSystemState)
    let keyCodeV = CGKeyCode(9)

    let keyDown = CGEvent(
      keyboardEventSource: source,
      virtualKey: keyCodeV,
      keyDown: true
    )
    keyDown?.flags = .maskCommand

    let keyUp = CGEvent(
      keyboardEventSource: source,
      virtualKey: keyCodeV,
      keyDown: false
    )
    keyUp?.flags = .maskCommand

    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)
  }
}
