import Carbon
import Foundation

final class GlobalHotkeyManager: @unchecked Sendable {
  var onHotkey: (() -> Void)?

  private var hotkeyRef: EventHotKeyRef?
  private var eventHandlerRef: EventHandlerRef?
  private let hotkeyID = EventHotKeyID(signature: fourCharCode("SYNP"), id: 1)

  init() {
    installHandler()
  }

  deinit {
    unregister()

    if let eventHandlerRef {
      RemoveEventHandler(eventHandlerRef)
    }
  }

  func register(_ hotkey: AppHotkey) -> OSStatus {
    unregister()

    var ref: EventHotKeyRef?
    let status = RegisterEventHotKey(
      hotkey.keyCode,
      hotkey.carbonModifiers,
      hotkeyID,
      GetApplicationEventTarget(),
      0,
      &ref
    )

    if status == noErr {
      hotkeyRef = ref
    }

    return status
  }

  func unregister() {
    if let hotkeyRef {
      UnregisterEventHotKey(hotkeyRef)
      self.hotkeyRef = nil
    }
  }

  private func installHandler() {
    var eventType = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )

    InstallEventHandler(
      GetApplicationEventTarget(),
      GlobalHotkeyManager.eventHandler,
      1,
      &eventType,
      Unmanaged.passUnretained(self).toOpaque(),
      &eventHandlerRef
    )
  }

  private static let eventHandler: EventHandlerUPP = { _, eventRef, userData in
    guard let eventRef, let userData else {
      return noErr
    }

    var eventHotkeyID = EventHotKeyID()
    let status = GetEventParameter(
      eventRef,
      EventParamName(kEventParamDirectObject),
      EventParamType(typeEventHotKeyID),
      nil,
      MemoryLayout<EventHotKeyID>.size,
      nil,
      &eventHotkeyID
    )

    guard status == noErr else {
      return status
    }

    let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    guard eventHotkeyID.id == manager.hotkeyID.id else {
      return noErr
    }

    DispatchQueue.main.async {
      manager.onHotkey?()
    }

    return noErr
  }
}

private func fourCharCode(_ value: String) -> OSType {
  value.utf8.reduce(0) { result, byte in
    (result << 8) + OSType(byte)
  }
}
