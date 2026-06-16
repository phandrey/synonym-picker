import AppKit
import Carbon

private enum ModelMenuState: Equatable {
  case checking
  case missingRuntime
  case needsDownload
  case downloading(Double)
  case starting
  case ready
  case failed(String)
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private let appState = AppState()
  private let hotkeyManager = GlobalHotkeyManager()
  private let selectionReader = SelectionReader()
  private let textReplacementService = TextReplacementService()
  private let synonymProvider = LocalSynonymProvider()
  private let llamaServerManager = LlamaServerManager()
  private var currentHotkey: AppHotkey?
  private var statusItem: NSStatusItem?
  private var statusMenu: NSMenu?
  private var hotkeyMenuItem: NSMenuItem?
  private var permissionsMenuItem: NSMenuItem?
  private var modelMenuItem: NSMenuItem?
  private var modelMenuState: ModelMenuState = .checking
  private var modelDownloadTask: Task<Void, Never>?
  private var modelProgressTask: Task<Void, Never>?
  private var settingsWindowController: SettingsWindowController?
  private var hotkeyRecorder: HotkeyRecorder?
  private var mockSuggestionsWindowController: MockSuggestionsWindowController?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    appState.onStartHotkeyRecording = { [weak self] in
      self?.startHotkeyRecording()
    }
    appState.onRequestAccessibilityPermission = { [weak self] in
      self?.requestAccessibilityPermission()
    }
    hotkeyManager.onHotkey = { [weak self] in
      self?.readSelectionAndShowMockSuggestions()
    }

    refreshAccessibilityPermission()
    loadSavedHotkey()
    configureStatusItem()
    startModelRuntime()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: NSApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  func applicationWillTerminate(_ notification: Notification) {
    modelDownloadTask?.cancel()
    modelProgressTask?.cancel()
    llamaServerManager.stop()
  }

  private func configureStatusItem() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.autosaveName = "SynonymPickerStatusItem"
    item.isVisible = true

    if let button = item.button {
      if let image = NSImage(
        systemSymbolName: "sparkles",
        accessibilityDescription: "Synonym Picker"
      ) {
        image.isTemplate = true
        image.size = NSSize(width: 16, height: 16)
        button.image = image
        button.imagePosition = .imageOnly
        button.title = ""
      } else {
        button.title = "Syn"
      }

      button.toolTip = "Synonym Picker"
    }

    let menu = NSMenu()
    menu.delegate = self

    let hotkeyItem = NSMenuItem(
      title: "Hotkey",
      action: #selector(recordHotkeyFromStatusMenu),
      keyEquivalent: ""
    )
    hotkeyItem.target = self
    menu.addItem(hotkeyItem)
    self.hotkeyMenuItem = hotkeyItem

    let permissionsItem = NSMenuItem(
      title: "Permissions",
      action: #selector(requestAccessibilityPermissionFromStatusMenu),
      keyEquivalent: ""
    )
    permissionsItem.target = self
    menu.addItem(permissionsItem)
    self.permissionsMenuItem = permissionsItem

    let modelItem = NSMenuItem(
      title: "Model: \(ModelCatalog.defaultProfile.shortName)",
      action: #selector(downloadModelFromStatusMenu),
      keyEquivalent: ""
    )
    modelItem.target = self
    menu.addItem(modelItem)
    self.modelMenuItem = modelItem

    menu.addItem(NSMenuItem.separator())

    let quitItem = NSMenuItem(
      title: "Quit Synonym Picker",
      action: #selector(quit),
      keyEquivalent: "q"
    )
    quitItem.target = self
    menu.addItem(quitItem)

    item.menu = menu
    statusMenu = menu
    statusItem = item
    refreshStatusMenuItems()
  }

  @objc private func openSettings() {
    if settingsWindowController == nil {
      settingsWindowController = SettingsWindowController(appState: appState)
    }

    settingsWindowController?.showWindow(nil)
    settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    settingsWindowController?.window?.orderFrontRegardless()
    NSRunningApplication.current.activate(options: [.activateAllWindows])
  }

  @objc private func recordHotkeyFromStatusMenu() {
    appState.startHotkeyRecording()
  }

  @objc private func requestAccessibilityPermissionFromStatusMenu() {
    appState.requestAccessibilityPermission()
  }

  @objc private func downloadModelFromStatusMenu() {
    startModelDownload()
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }

  @objc private func applicationDidBecomeActive() {
    refreshAccessibilityPermission()
  }

  private func loadSavedHotkey() {
    let hotkey = HotkeyStore.load()
    currentHotkey = hotkey
    appState.load(hotkey: hotkey)
    refreshStatusMenuItems()

    if let hotkey {
      _ = hotkeyManager.register(hotkey)
    }
  }

  private func startHotkeyRecording() {
    hotkeyRecorder?.stop()
    hotkeyManager.unregister()
    refreshStatusMenuItems()
    NSApp.activate(ignoringOtherApps: true)

    hotkeyRecorder = HotkeyRecorder { [weak self] hotkey in
      guard let self else {
        return
      }

      guard let hotkey else {
        self.appState.cancelHotkeyRecording()
        self.restoreCurrentHotkey()
        self.refreshStatusMenuItems()
        return
      }

      let status = self.hotkeyManager.register(hotkey)
      if status == noErr {
        self.currentHotkey = hotkey
        HotkeyStore.save(hotkey)
        self.appState.finishHotkeyRecording(hotkey, status: "Registered")
        self.refreshStatusMenuItems()
      } else {
        self.restoreCurrentHotkey()
        self.appState.finishHotkeyRecording(hotkey, status: "Conflict")
        self.refreshStatusMenuItems()
      }
    }
  }

  private func restoreCurrentHotkey() {
    if let currentHotkey {
      _ = hotkeyManager.register(currentHotkey)
    }
  }

  private func readSelectionAndShowMockSuggestions() {
    refreshAccessibilityPermission()
    appState.setModelStatus("Checking")

    let sourceApplication = NSWorkspace.shared.frontmostApplication

    selectionReader.readSelection { [weak self] result in
      self?.hideSettings()
      self?.resolveSuggestionsAndShow(result: result, sourceApplication: sourceApplication)
    }
  }

  private func resolveSuggestionsAndShow(
    result: SelectionReadResult,
    sourceApplication: NSRunningApplication?
  ) {
    guard let selectedText = result.selectedText else {
      appState.setModelStatus("External")
      showSuggestions(
        payload: .selectionFailure(result),
        sourceApplication: sourceApplication
      )
      return
    }

    Task { @MainActor in
      guard llamaServerManager.isModelDownloaded() else {
        modelMenuState = .needsDownload
        appState.setModelStatus("Download")
        refreshStatusMenuItems()
        showSuggestions(
          payload: .modelFailure(
            selectedText: selectedText,
            message: "Click Model: Download in the menu bar before using suggestions"
          ),
          sourceApplication: sourceApplication
        )
        return
      }

      modelMenuState = .starting
      refreshStatusMenuItems()
      let runtimeStatus = await llamaServerManager.startIfNeeded(waitTimeout: 5)
      applyRuntimeStatus(runtimeStatus)

      guard runtimeStatus.isReadyForSuggestions else {
        showSuggestions(
          payload: .modelFailure(
            selectedText: selectedText,
            message: modelRuntimeFailureMessage(for: runtimeStatus)
          ),
          sourceApplication: sourceApplication
        )
        return
      }

      do {
        let suggestions = try await synonymProvider.suggestions(
          for: selectedText,
          context: result.context
        )
        appState.setModelStatus("Ready")
        showSuggestions(
          payload: .suggestions(selectedText: selectedText, suggestions: suggestions),
          sourceApplication: sourceApplication
        )
      } catch {
        appState.setModelStatus(modelStatus(for: error))
        showSuggestions(
          payload: suggestionFailurePayload(for: error, selectedText: selectedText),
          sourceApplication: sourceApplication
        )
      }
    }
  }

  private func requestAccessibilityPermission() {
    AccessibilityPermissionService.requestPrompt()
    openAccessibilitySettings()
    refreshAccessibilityPermission()
    refreshStatusMenuItems()

    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 500_000_000)
      refreshAccessibilityPermission()
      refreshStatusMenuItems()
    }
  }

  private func refreshAccessibilityPermission() {
    appState.refreshAccessibilityPermission(isTrusted: AccessibilityPermissionService.isTrusted)
    refreshStatusMenuItems()
  }

  private func refreshStatusMenuItems() {
    refreshModelMenuStateFromCache()

    hotkeyMenuItem?.title =
      appState.isRecordingHotkey
      ? "Hotkey: Press keys..."
      : "Hotkey: \(appState.hotkeyDisplay)"
    hotkeyMenuItem?.isEnabled = true

    permissionsMenuItem?.title =
      appState.hasAccessibilityPermission
      ? "Permissions: Accessibility Granted"
      : "Permissions: Request Accessibility"
    permissionsMenuItem?.isEnabled = true

    modelMenuItem?.title = modelMenuTitle
    modelMenuItem?.isEnabled = isModelMenuActionEnabled
  }

  private func refreshModelMenuStateFromCache() {
    guard llamaServerManager.isModelDownloaded() else {
      return
    }

    switch modelMenuState {
    case .checking, .needsDownload, .downloading:
      modelMenuState = .ready
    case .missingRuntime, .starting, .ready, .failed:
      break
    }
  }

  private func openAccessibilitySettings() {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    else {
      return
    }

    NSWorkspace.shared.open(url)
  }

  private func hideSettings() {
    settingsWindowController?.window?.orderOut(nil)
  }

  private func showSuggestions(
    payload: SuggestionPopupPayload,
    sourceApplication: NSRunningApplication?
  ) {
    if mockSuggestionsWindowController == nil {
      mockSuggestionsWindowController = MockSuggestionsWindowController()
    }

    mockSuggestionsWindowController?.show(
      payload: payload,
      sourceApplication: sourceApplication
    ) { [weak self] suggestion, application in
      self?.textReplacementService.replaceSelection(with: suggestion, in: application)
    }
  }

  private func modelFailureMessage(for error: Error) -> String {
    if let providerError = error as? LocalSynonymProviderError {
      switch providerError {
      case .serverUnavailable:
        return modelRuntimeFailureMessage(for: .starting)
      case .emptyResponse:
        return "Local model returned an empty response"
      case .noUsableSuggestions:
        return "Model response was filtered out as not useful for this context"
      }
    }

    return "Local model is not ready"
  }

  private func modelStatus(for error: Error) -> String {
    if let providerError = error as? LocalSynonymProviderError {
      switch providerError {
      case .noUsableSuggestions:
        return "Ready"
      case .serverUnavailable, .emptyResponse:
        return "Offline"
      }
    }

    return "Offline"
  }

  private func suggestionFailurePayload(
    for error: Error,
    selectedText: String
  ) -> SuggestionPopupPayload {
    if let providerError = error as? LocalSynonymProviderError,
      providerError == .noUsableSuggestions
    {
      return .noUsableSuggestions(
        selectedText: selectedText,
        message: modelFailureMessage(for: error)
      )
    }

    return .modelFailure(
      selectedText: selectedText,
      message: modelFailureMessage(for: error)
    )
  }

  private func startModelRuntime() {
    modelMenuState = .checking
    appState.setModelStatus("Checking")
    refreshStatusMenuItems()

    Task { @MainActor in
      guard llamaServerManager.isModelDownloaded() else {
        modelMenuState = .needsDownload
        appState.setModelStatus("Download")
        refreshStatusMenuItems()
        return
      }

      modelMenuState = .starting
      refreshStatusMenuItems()
      let runtimeStatus = await llamaServerManager.startIfNeeded(waitTimeout: 5)
      applyRuntimeStatus(runtimeStatus)
    }
  }

  private func startModelDownload() {
    guard modelDownloadTask == nil else {
      return
    }

    modelMenuState = .downloading(llamaServerManager.modelDownloadProgress())
    appState.setModelStatus("Downloading")
    refreshStatusMenuItems()

    modelProgressTask?.cancel()
    modelProgressTask = Task { @MainActor in
      while !Task.isCancelled {
        modelMenuState = .downloading(llamaServerManager.modelDownloadProgress())
        refreshStatusMenuItems()
        try? await Task.sleep(nanoseconds: 500_000_000)
      }
    }

    modelDownloadTask = Task { @MainActor in
      let runtimeStatus = await llamaServerManager.startIfNeeded(waitTimeout: 60 * 60)
      modelProgressTask?.cancel()
      modelProgressTask = nil
      modelDownloadTask = nil
      applyRuntimeStatus(runtimeStatus)
    }
  }

  private func applyRuntimeStatus(_ runtimeStatus: LlamaServerManager.RuntimeStatus) {
    appState.setModelStatus(runtimeStatus.modelTileStatus)

    switch runtimeStatus {
    case .missingRuntime:
      modelMenuState = .missingRuntime
    case .starting:
      modelMenuState = .downloading(llamaServerManager.modelDownloadProgress())
    case .runningExternal, .runningManaged:
      modelMenuState = .ready
    case .failed(let message):
      modelMenuState = .failed(message)
    }

    refreshStatusMenuItems()
  }

  private var modelMenuTitle: String {
    let modelName = ModelCatalog.defaultProfile.shortName

    switch modelMenuState {
    case .checking:
      return "Model: \(modelName)  Checking"
    case .missingRuntime:
      return "Model: Install llama.cpp"
    case .needsDownload:
      return "Model: \(modelName)  ↓ Download"
    case .downloading(let progress):
      return "Model: \(modelName)  \(Int(progress * 100))%"
    case .starting:
      return "Model: \(modelName)  Starting"
    case .ready:
      return "Model: \(modelName)  ✓"
    case .failed:
      return "Model: \(modelName)  Retry Download"
    }
  }

  private var isModelMenuActionEnabled: Bool {
    switch modelMenuState {
    case .needsDownload, .failed:
      true
    case .checking, .missingRuntime, .downloading, .starting, .ready:
      false
    }
  }

  private func modelRuntimeFailureMessage(
    for status: LlamaServerManager.RuntimeStatus
  ) -> String {
    switch status {
    case .missingRuntime:
      return "llama-server is not installed. Install: brew install llama.cpp"
    case .starting:
      return "Local model is still starting. Try the hotkey again in a few seconds."
    case .runningExternal, .runningManaged:
      return "Local model is ready"
    case .failed(let message):
      return message
    }
  }
}

extension LlamaServerManager.RuntimeStatus {
  fileprivate var isReadyForSuggestions: Bool {
    switch self {
    case .runningExternal, .runningManaged:
      true
    case .missingRuntime, .starting, .failed:
      false
    }
  }
}

extension AppDelegate: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    refreshAccessibilityPermission()
    refreshStatusMenuItems()
  }
}
