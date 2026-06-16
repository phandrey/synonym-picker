import AppKit
import Foundation

struct PasteboardSnapshot: Sendable {
  private struct Item: Sendable {
    let values: [(type: NSPasteboard.PasteboardType, data: Data)]
  }

  private let items: [Item]

  static func capture(from pasteboard: NSPasteboard) -> PasteboardSnapshot {
    let items: [Item] =
      pasteboard.pasteboardItems?.map { item in
        let values = item.types.compactMap { type in
          item.data(forType: type).map { data in
            (type: type, data: data)
          }
        }

        return Item(values: values)
      } ?? []

    return PasteboardSnapshot(items: items)
  }

  func restore(to pasteboard: NSPasteboard) {
    pasteboard.clearContents()

    let restoredItems = items.map { snapshotItem in
      let item = NSPasteboardItem()

      for value in snapshotItem.values {
        item.setData(value.data, forType: value.type)
      }

      return item
    }

    pasteboard.writeObjects(restoredItems)
  }
}
