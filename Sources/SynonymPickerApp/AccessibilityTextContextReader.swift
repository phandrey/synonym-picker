import ApplicationServices
import Foundation
import SynonymPickerCore

@MainActor
final class AccessibilityTextContextReader {
  func readContext() -> TextContext? {
    guard AccessibilityPermissionService.isTrusted else {
      return nil
    }

    guard let focusedElement = focusedUIElement() else {
      return nil
    }

    guard let selectedRange = selectedTextRange(from: focusedElement),
      let fullText = stringAttribute(kAXValueAttribute, from: focusedElement)
    else {
      return nil
    }

    return TextContextExtractor.context(
      in: fullText,
      selectedRange: selectedRange
    )
  }

  private func focusedUIElement() -> AXUIElement? {
    let systemElement = AXUIElementCreateSystemWide()
    var focusedElement: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
      systemElement,
      kAXFocusedUIElementAttribute as CFString,
      &focusedElement
    )

    guard result == .success else {
      return nil
    }

    guard let focusedElement,
      CFGetTypeID(focusedElement) == AXUIElementGetTypeID()
    else {
      return nil
    }

    return (focusedElement as! AXUIElement)
  }

  private func selectedTextRange(from element: AXUIElement) -> NSRange? {
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
      element,
      kAXSelectedTextRangeAttribute as CFString,
      &value
    )

    guard result == .success, let axValue = value else {
      return nil
    }

    var range = CFRange()
    guard CFGetTypeID(axValue) == AXValueGetTypeID(),
      AXValueGetValue((axValue as! AXValue), .cfRange, &range)
    else {
      return nil
    }

    return NSRange(location: range.location, length: range.length)
  }

  private func stringAttribute(_ attribute: String, from element: AXUIElement) -> String? {
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(
      element,
      attribute as CFString,
      &value
    )

    guard result == .success else {
      return nil
    }

    return value as? String
  }
}
