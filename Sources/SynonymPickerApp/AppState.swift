import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
  @Published private(set) var hotkeyDisplay = "Not configured"
  @Published private(set) var hotkeyStatus = "Click to set"
  @Published private(set) var isRecordingHotkey = false
  @Published private(set) var permissionSubtitle = "Accessibility"
  @Published private(set) var permissionStatus = "Request"
  @Published private(set) var hasAccessibilityPermission = false
  @Published private(set) var modelSubtitle = ModelCatalog.defaultProfile.shortName
  @Published private(set) var modelStatus = "External"

  var onStartHotkeyRecording: (() -> Void)?
  var onRequestAccessibilityPermission: (() -> Void)?

  func load(hotkey: AppHotkey?) {
    if let hotkey {
      hotkeyDisplay = hotkey.displayTitle
      hotkeyStatus = "Registered"
    } else {
      hotkeyDisplay = "Not configured"
      hotkeyStatus = "Click to set"
    }
  }

  func startHotkeyRecording() {
    isRecordingHotkey = true
    hotkeyDisplay = "Press keys..."
    hotkeyStatus = "Recording"
    onStartHotkeyRecording?()
  }

  func refreshAccessibilityPermission(isTrusted: Bool) {
    hasAccessibilityPermission = isTrusted
    permissionSubtitle = isTrusted ? "Accessibility" : "Required"
    permissionStatus = isTrusted ? "Granted" : "Request"
  }

  func requestAccessibilityPermission() {
    onRequestAccessibilityPermission?()
  }

  func setModelStatus(_ status: String) {
    modelSubtitle = ModelCatalog.defaultProfile.shortName
    modelStatus = status
  }

  func finishHotkeyRecording(_ hotkey: AppHotkey, status: String) {
    isRecordingHotkey = false
    hotkeyDisplay = hotkey.displayTitle
    hotkeyStatus = status
  }

  func cancelHotkeyRecording() {
    isRecordingHotkey = false
    hotkeyStatus = hotkeyDisplay == "Press keys..." ? "Click to set" : hotkeyStatus
    if hotkeyDisplay == "Press keys..." {
      hotkeyDisplay = "Not configured"
    }
  }
}
