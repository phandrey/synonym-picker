import AppKit
import CoreGraphics
import Foundation
import SynonymPickerCore

struct SelectionReadResult: Equatable, Sendable {
  let selectedText: String?
  let context: TextContext?
  let message: String

  var hasSelection: Bool {
    selectedText != nil
  }

  static func success(_ text: String, context: TextContext?) -> SelectionReadResult {
    SelectionReadResult(
      selectedText: text,
      context: context,
      message: "Selection captured"
    )
  }

  static func empty() -> SelectionReadResult {
    SelectionReadResult(
      selectedText: nil,
      context: nil,
      message: "No selected text"
    )
  }

  static func failure(_ message: String) -> SelectionReadResult {
    SelectionReadResult(selectedText: nil, context: nil, message: message)
  }
}

@MainActor
final class SelectionReader {
  private let pasteboard: NSPasteboard
  private let contextReader: AccessibilityTextContextReader
  private let pollIntervalNanoseconds: UInt64
  private let timeoutNanoseconds: UInt64

  init(
    pasteboard: NSPasteboard = .general,
    contextReader: AccessibilityTextContextReader = AccessibilityTextContextReader(),
    pollIntervalNanoseconds: UInt64 = 50_000_000,
    timeoutNanoseconds: UInt64 = 1_200_000_000
  ) {
    self.pasteboard = pasteboard
    self.contextReader = contextReader
    self.pollIntervalNanoseconds = pollIntervalNanoseconds
    self.timeoutNanoseconds = timeoutNanoseconds
  }

  func readSelection(completion: @escaping @MainActor (SelectionReadResult) -> Void) {
    let isAccessibilityTrusted = AccessibilityPermissionService.isTrusted
    let context = contextReader.readContext()
    let snapshot = PasteboardSnapshot.capture(from: pasteboard)

    pasteboard.clearContents()
    let baselineChangeCount = pasteboard.changeCount
    postCopyShortcut()

    Task { @MainActor in
      let deadline = ContinuousClock.now.advanced(
        by: .nanoseconds(Int(timeoutNanoseconds))
      )

      while pasteboard.changeCount == baselineChangeCount && ContinuousClock.now < deadline {
        try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
      }

      let text = pasteboard.string(forType: .string)?
        .trimmingCharacters(in: .whitespacesAndNewlines)

      snapshot.restore(to: pasteboard)

      guard let text, !text.isEmpty else {
        if !isAccessibilityTrusted {
          completion(.failure("Accessibility permission is not active"))
        } else if pasteboard.changeCount == baselineChangeCount {
          completion(.failure("The source app did not copy selected text"))
        } else {
          completion(.failure("Copied selection is empty or not text"))
        }
        return
      }

      completion(.success(text, context: context))
    }
  }

  private func postCopyShortcut() {
    let source = CGEventSource(stateID: .hidSystemState)
    let keyCodeC = CGKeyCode(8)

    let keyDown = CGEvent(
      keyboardEventSource: source,
      virtualKey: keyCodeC,
      keyDown: true
    )
    keyDown?.flags = .maskCommand

    let keyUp = CGEvent(
      keyboardEventSource: source,
      virtualKey: keyCodeC,
      keyDown: false
    )
    keyUp?.flags = .maskCommand

    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)
  }
}
