import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
  init(appState: AppState) {
    let rootView = SettingsView(appState: appState)
    let hostingController = NSHostingController(rootView: rootView)

    let window = NSWindow(contentViewController: hostingController)
    window.title = "Synonym Picker"
    window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
    window.titlebarAppearsTransparent = true
    window.isMovableByWindowBackground = true
    window.backgroundColor = .clear
    window.contentView?.wantsLayer = true
    window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    window.center()

    super.init(window: window)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }
}
