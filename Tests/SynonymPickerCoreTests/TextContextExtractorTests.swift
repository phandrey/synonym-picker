import Foundation
import SynonymPickerCore
import Testing

@Test func contextKeepsNearbySentenceAroundSelection() {
  let text = "Первое предложение. Матвей срал в туалете, пока Алим тоже срал. Третье предложение."
  let range = (text as NSString).range(of: "срал")

  let context = TextContextExtractor.context(in: text, selectedRange: range, maxCharacters: 80)

  #expect(context?.text == "Матвей срал в туалете, пока Алим тоже срал.")
  #expect(context?.selectedSentence == "Матвей срал в туалете, пока Алим тоже срал.")
}

@Test func contextReturnsSmallFullTextWithoutCropping() {
  let text = "Легкий текст без лишней длины."
  let range = (text as NSString).range(of: "Легкий")

  let context = TextContextExtractor.context(in: text, selectedRange: range, maxCharacters: 420)

  #expect(context?.text == text)
  #expect(context?.selectedSentence == text)
}

@Test func contextCarriesSelectedSentenceInsideWiderContext() {
  let text = "Первое предложение. Второе предложение с важным словом. Третье предложение рядом."
  let range = (text as NSString).range(of: "важным")

  let context = TextContextExtractor.context(in: text, selectedRange: range, maxCharacters: 140)

  #expect(context?.text == text)
  #expect(context?.selectedSentence == "Второе предложение с важным словом.")
}

@Test func contextRejectsInvalidRange() {
  let context = TextContextExtractor.context(
    in: "Текст",
    selectedRange: NSRange(location: NSNotFound, length: 0)
  )

  #expect(context == nil)
}
