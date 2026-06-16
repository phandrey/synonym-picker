import AppKit

@MainActor
final class HotkeyRecorder {
  private var localEventMonitor: Any?
  private var globalEventMonitor: Any?
  private let onRecord: (AppHotkey?) -> Void

  init(onRecord: @escaping (AppHotkey?) -> Void) {
    self.onRecord = onRecord

    localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else {
        return event
      }

      return self.record(event) ? nil : event
    }

    globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
      [weak self] event in
      Task { @MainActor in
        _ = self?.record(event)
      }
    }
  }

  private func record(_ event: NSEvent) -> Bool {
    if event.keyCode == 53 {
      stop()
      onRecord(nil)
      return true
    }

    guard let hotkey = AppHotkey.from(event: event) else {
      return true
    }

    stop()
    onRecord(hotkey)
    return true
  }

  func stop() {
    if let localEventMonitor {
      NSEvent.removeMonitor(localEventMonitor)
      self.localEventMonitor = nil
    }

    if let globalEventMonitor {
      NSEvent.removeMonitor(globalEventMonitor)
      self.globalEventMonitor = nil
    }
  }
}
