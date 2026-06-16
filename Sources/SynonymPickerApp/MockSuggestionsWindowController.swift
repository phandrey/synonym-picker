import AppKit
import SwiftUI

private let suggestionsOverlayCollectionBehavior: NSWindow.CollectionBehavior = [
  .canJoinAllApplications,
  .canJoinAllSpaces,
  .fullScreenAuxiliary,
  .ignoresCycle,
  .stationary,
]

private let dockBundleIdentifier = "com.apple.dock"

@MainActor
private final class SuggestionSelectionState: ObservableObject {
  let suggestions: [String]

  @Published private(set) var selectedIndex = 0

  init(suggestions: [String]) {
    self.suggestions = suggestions
  }

  var selectedSuggestion: String? {
    guard suggestions.indices.contains(selectedIndex) else {
      return nil
    }

    return suggestions[selectedIndex]
  }

  func moveDown() {
    guard !suggestions.isEmpty else {
      return
    }

    selectedIndex = min(selectedIndex + 1, suggestions.count - 1)
  }

  func moveUp() {
    guard !suggestions.isEmpty else {
      return
    }

    selectedIndex = max(selectedIndex - 1, 0)
  }

  func select(index: Int) {
    guard suggestions.indices.contains(index) else {
      return
    }

    selectedIndex = index
  }
}

private final class SuggestionsPanel: NSPanel {
  override var canBecomeKey: Bool {
    true
  }

  override var canBecomeMain: Bool {
    false
  }
}

@MainActor
final class MockSuggestionsWindowController: NSWindowController, NSWindowDelegate {
  private var keyEventMonitor: Any?
  private var localMouseEventMonitor: Any?
  private var globalMouseEventMonitor: Any?
  private var pendingPresentationWorkItem: DispatchWorkItem?
  private var pendingPresentationID: UUID?
  private var selectionState: SuggestionSelectionState?
  private var sourceApplication: NSRunningApplication?
  private var onChoose: ((String, NSRunningApplication?) -> Void)?

  init() {
    let rootView = MockSuggestionsView(
      payload: .selectionFailure(.empty()),
      selectionState: SuggestionSelectionState(suggestions: []),
      onDismiss: {},
      onChoose: { _ in }
    )
    let hostingController = NSHostingController(rootView: rootView)

    let panel = SuggestionsPanel(contentViewController: hostingController)
    panel.title = "Suggestions"
    panel.styleMask = [.hudWindow, .nonactivatingPanel]
    panel.level = .screenSaver
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = true
    panel.hidesOnDeactivate = false
    panel.backgroundColor = .clear
    panel.collectionBehavior = suggestionsOverlayCollectionBehavior
    panel.contentView?.wantsLayer = true
    panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

    super.init(window: panel)
    panel.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  func show(
    payload: SuggestionPopupPayload,
    sourceApplication: NSRunningApplication?,
    onChoose: @escaping (String, NSRunningApplication?) -> Void
  ) {
    guard let window else {
      return
    }

    let selectionState = SuggestionSelectionState(suggestions: payload.suggestions)
    self.selectionState = selectionState
    self.sourceApplication = sourceApplication
    self.onChoose = onChoose

    cancelPendingPresentation()
    stopDismissLifecycle()

    guard !isMissionControlApplication(sourceApplication) else {
      window.orderOut(nil)
      return
    }

    window.contentViewController = NSHostingController(
      rootView: MockSuggestionsView(
        payload: payload,
        selectionState: selectionState,
        onDismiss: { [weak self] in
          self?.dismissPopup()
        },
        onChoose: { [weak self] suggestion in
          self?.choose(suggestion)
        }
      )
    )

    window.orderOut(nil)

    let restoredSourceApplication = restoreSourceApplicationForPresentation(sourceApplication)
    let presentationDelay = restoredSourceApplication ? 0.15 : 0
    schedulePresentation(
      payload: payload,
      sourceProcessIdentifier: sourceApplication?.processIdentifier,
      delay: presentationDelay,
      missionControlRetryCount: 0
    )
  }

  func windowWillClose(_ notification: Notification) {
    cancelPendingPresentation()
    stopDismissLifecycle()
  }

  private func schedulePresentation(
    payload: SuggestionPopupPayload,
    sourceProcessIdentifier: pid_t?,
    delay: TimeInterval,
    missionControlRetryCount: Int
  ) {
    cancelPendingPresentation()

    let presentationID = UUID()
    let workItem = DispatchWorkItem { [weak self] in
      Task { @MainActor [weak self] in
        self?.presentWindow(
          payload: payload,
          sourceProcessIdentifier: sourceProcessIdentifier,
          missionControlRetryCount: missionControlRetryCount,
          presentationID: presentationID
        )
      }
    }
    pendingPresentationID = presentationID
    pendingPresentationWorkItem = workItem

    if delay > 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    } else {
      DispatchQueue.main.async(execute: workItem)
    }
  }

  private func presentWindow(
    payload: SuggestionPopupPayload,
    sourceProcessIdentifier: pid_t?,
    missionControlRetryCount: Int,
    presentationID: UUID
  ) {
    guard let window, pendingPresentationID == presentationID else {
      return
    }

    pendingPresentationID = nil
    pendingPresentationWorkItem = nil

    if let sourceProcessIdentifier,
      sourceApplication?.processIdentifier != sourceProcessIdentifier
    {
      return
    }

    if isMissionControlActive() {
      guard missionControlRetryCount < 3 else {
        return
      }

      schedulePresentation(
        payload: payload,
        sourceProcessIdentifier: sourceProcessIdentifier,
        delay: 0.2,
        missionControlRetryCount: missionControlRetryCount + 1
      )
      return
    }

    if let screenFrame = targetScreen()?.visibleFrame {
      let size = window.contentViewController?.view.fittingSize ?? NSSize(width: 260, height: 210)
      window.setFrame(
        NSRect(
          x: screenFrame.midX - size.width / 2,
          y: screenFrame.midY - size.height / 2,
          width: size.width,
          height: size.height
        ),
        display: true
      )
    }

    window.level = .screenSaver
    window.collectionBehavior = suggestionsOverlayCollectionBehavior
    window.orderFrontRegardless()
    startDismissLifecycle(payload: payload)
  }

  private func cancelPendingPresentation() {
    pendingPresentationWorkItem?.cancel()
    pendingPresentationWorkItem = nil
    pendingPresentationID = nil
  }

  private func restoreSourceApplicationForPresentation(
    _ application: NSRunningApplication?
  ) -> Bool {
    guard let application,
      shouldRestoreSourceApplication(application),
      shouldTakeFocusBackToSourceApplication(application)
    else {
      return false
    }

    return application.activate(options: [])
  }

  private func shouldRestoreSourceApplication(_ application: NSRunningApplication) -> Bool {
    guard !application.isTerminated else {
      return false
    }

    guard application.processIdentifier != NSRunningApplication.current.processIdentifier else {
      return false
    }

    return !isMissionControlApplication(application)
  }

  private func shouldTakeFocusBackToSourceApplication(
    _ application: NSRunningApplication
  ) -> Bool {
    guard !application.isActive else {
      return false
    }

    guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else {
      return true
    }

    if frontmostApplication.processIdentifier == application.processIdentifier {
      return false
    }

    if frontmostApplication.processIdentifier == NSRunningApplication.current.processIdentifier {
      return true
    }

    return isMissionControlApplication(frontmostApplication)
  }

  private func isMissionControlActive() -> Bool {
    guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else {
      return false
    }

    return isMissionControlApplication(frontmostApplication)
  }

  private func isMissionControlApplication(_ application: NSRunningApplication?) -> Bool {
    application?.bundleIdentifier == dockBundleIdentifier
  }

  private func startDismissLifecycle(payload: SuggestionPopupPayload) {
    stopDismissLifecycle()

    keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self else {
        return event
      }

      if event.keyCode == 53 {
        self.dismissPopup()
        return nil
      }

      if event.keyCode == 125 {
        self.selectionState?.moveDown()
        return nil
      }

      if event.keyCode == 126 {
        self.selectionState?.moveUp()
        return nil
      }

      if event.keyCode == 36 || event.keyCode == 76 {
        if let suggestion = self.selectionState?.selectedSuggestion {
          self.choose(suggestion)
        }
        return nil
      }

      return event
    }

    let mouseMask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
    localMouseEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mouseMask) {
      [weak self] event in
      self?.dismissIfClickOutsidePopup()
      return event
    }

    globalMouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mouseMask) {
      [weak self] _ in
      Task { @MainActor in
        self?.dismissIfClickOutsidePopup()
      }
    }

    let delay = payload.hasSuggestions ? 12.0 : 6.0
    perform(#selector(dismissPopup), with: nil, afterDelay: delay)
  }

  private func stopDismissLifecycle() {
    NSObject.cancelPreviousPerformRequests(
      withTarget: self,
      selector: #selector(dismissPopup),
      object: nil
    )

    if let keyEventMonitor {
      NSEvent.removeMonitor(keyEventMonitor)
      self.keyEventMonitor = nil
    }

    if let localMouseEventMonitor {
      NSEvent.removeMonitor(localMouseEventMonitor)
      self.localMouseEventMonitor = nil
    }

    if let globalMouseEventMonitor {
      NSEvent.removeMonitor(globalMouseEventMonitor)
      self.globalMouseEventMonitor = nil
    }
  }

  private func targetScreen() -> NSScreen? {
    let mouseLocation = NSEvent.mouseLocation
    return NSScreen.screens.first { screen in
      screen.frame.contains(mouseLocation)
    } ?? NSScreen.main
  }

  @objc private func dismissPopup() {
    cancelPendingPresentation()
    stopDismissLifecycle()
    window?.orderOut(nil)
  }

  private func dismissIfClickOutsidePopup() {
    guard let window, window.isVisible else {
      return
    }

    let clickLocation = NSEvent.mouseLocation
    guard !window.frame.insetBy(dx: -4, dy: -4).contains(clickLocation) else {
      return
    }

    dismissPopup()
  }

  private func choose(_ suggestion: String) {
    let application = sourceApplication
    let handler = onChoose

    dismissPopup()
    handler?(suggestion, application)
  }
}

private struct MockSuggestionsView: View {
  let payload: SuggestionPopupPayload
  @ObservedObject var selectionState: SuggestionSelectionState
  let onDismiss: () -> Void
  let onChoose: (String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Image(systemName: payload.hasSuggestions ? "sparkles" : "exclamationmark.circle")
        Text(payload.title)
          .font(.system(.body, weight: .semibold))
      }
      .foregroundStyle(.primary)

      if let selectedText = payload.selectedText {
        selectedTextView(selectedText)
        if payload.hasSuggestions {
          suggestionList
        } else {
          fallbackView
        }
      } else {
        fallbackView
      }
    }
    .padding(12)
    .frame(width: 250)
    .background {
      RoundedRectangle(cornerRadius: 14)
        .fill(.ultraThinMaterial)
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(.white.opacity(0.16), lineWidth: 1)
        }
    }
  }

  private func selectedTextView(_ text: String) -> some View {
    Text(text)
      .font(.caption)
      .foregroundStyle(.secondary)
      .lineLimit(2)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 10)
      .padding(.vertical, 7)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  private var suggestionList: some View {
    VStack(alignment: .leading, spacing: 6) {
      ForEach(Array(selectionState.suggestions.enumerated()), id: \.offset) { index, suggestion in
        Button {
          selectionState.select(index: index)
          onChoose(suggestion)
        } label: {
          HStack(spacing: 8) {
            Text(suggestion)
              .font(.system(.body, weight: .medium))

            Spacer()

            if index == selectionState.selectedIndex {
              Image(systemName: "return")
                .font(.caption)
                .symbolRenderingMode(.hierarchical)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 10)
          .padding(.vertical, 7)
          .background(rowBackground(isSelected: index == selectionState.selectedIndex))
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
      }
    }
  }

  private var fallbackView: some View {
    Text(payload.message)
      .font(.caption)
      .foregroundStyle(.secondary)
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .contentShape(RoundedRectangle(cornerRadius: 8))
      .onTapGesture(perform: onDismiss)
  }

  private func rowBackground(isSelected: Bool) -> some ShapeStyle {
    isSelected
      ? AnyShapeStyle(Color(red: 0.82, green: 0.13, blue: 0.52).opacity(0.64))
      : AnyShapeStyle(.ultraThinMaterial)
  }
}
