import SynonymPickerCore
import Testing

@Test func keepsLowercaseReplacementForLowercaseOriginal() {
  #expect(
    TextCasePreserver.applyingCase(of: "дом", to: "жилье") == "жилье"
  )
}

@Test func capitalizesReplacementForCapitalizedOriginal() {
  #expect(
    TextCasePreserver.applyingCase(of: "Дом", to: "жилье") == "Жилье"
  )
}

@Test func uppercasesReplacementForUppercaseOriginal() {
  #expect(
    TextCasePreserver.applyingCase(of: "FAST", to: "quick") == "QUICK"
  )
}
