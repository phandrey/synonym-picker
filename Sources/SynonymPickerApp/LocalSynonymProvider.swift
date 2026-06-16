import Foundation
import SynonymPickerCore

enum LocalSynonymProviderError: Error, Equatable {
  case serverUnavailable
  case emptyResponse
  case noUsableSuggestions
}

final class LocalSynonymProvider: Sendable {
  private let targetSuggestionCount = 8
  private let requestTimeout: TimeInterval = 6.5
  private let repairRequestTimeout: TimeInterval = 4.5
  private let endpoint: URL
  private let model: LocalModelProfile
  private let urlSession: URLSession

  init(
    endpoint: URL = URL(string: "http://127.0.0.1:8080/v1/chat/completions")!,
    model: LocalModelProfile = ModelCatalog.defaultProfile,
    urlSession: URLSession = .shared
  ) {
    self.endpoint = endpoint
    self.model = model
    self.urlSession = urlSession
  }

  func suggestions(for selectedText: String, context: TextContext?) async throws -> [String] {
    var normalized = normalizedSuggestions(
      rawSuggestions: try await requestSuggestions(
        selectedText: selectedText,
        context: context,
        repairAttempt: false
      ),
      selectedText: selectedText
    )

    if normalized.isEmpty {
      normalized = normalizedSuggestions(
        rawSuggestions: try await requestSuggestions(
          selectedText: selectedText,
          context: context,
          repairAttempt: true
        ),
        selectedText: selectedText
      )
    }

    guard !normalized.isEmpty else {
      throw LocalSynonymProviderError.noUsableSuggestions
    }

    return normalized
  }

  private func requestSuggestions(
    selectedText: String,
    context: TextContext?,
    repairAttempt: Bool
  ) async throws -> [RankedSynonymCandidate] {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.timeoutInterval = repairAttempt ? repairRequestTimeout : requestTimeout
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(
      makeRequest(
        selectedText: selectedText,
        context: context,
        repairAttempt: repairAttempt
      )
    )

    let data: Data
    let response: URLResponse

    do {
      (data, response) = try await urlSession.data(for: request)
    } catch {
      throw LocalSynonymProviderError.serverUnavailable
    }

    guard let httpResponse = response as? HTTPURLResponse,
      (200..<300).contains(httpResponse.statusCode)
    else {
      throw LocalSynonymProviderError.serverUnavailable
    }

    let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    guard let content = completion.choices.first?.message.content else {
      throw LocalSynonymProviderError.emptyResponse
    }

    return SynonymResponseParser.parse(content)
  }

  private func normalizedSuggestions(
    rawSuggestions: [RankedSynonymCandidate],
    selectedText: String
  ) -> [String] {
    let normalized = SynonymPostProcessor.normalizeRanked(
      rawCandidates: rawSuggestions,
      selectedWord: selectedText,
      limit: targetSuggestionCount
    )

    return normalized.map {
      TextCasePreserver.applyingCase(of: selectedText, to: $0)
    }
  }

  private func makeRequest(
    selectedText: String,
    context: TextContext?,
    repairAttempt: Bool
  ) -> ChatCompletionRequest {
    let contextInstruction: String
    if let context {
      let sentence = context.selectedSentence ?? context.text
      contextInstruction =
        """
        Короткий контекст: \(context.text)
        Предложение: \(sentence)
        Задача: заменить только выделенное слово в этом предложении.
        """
    } else {
      contextInstruction =
        """
        Контекст недоступен. Работай только с данным словом, но не исправляй его на похожее по буквам.
        """
    }

    let repairInstruction =
      repairAttempt
      ? """
      Первый ответ был полностью отфильтрован: модель повторила исходное слово или дала ту же лексему.
      Верни только новые лексемы. Запрещено возвращать "\(selectedText)", его формы, однокоренные слова и фразы с ним.
      Если вариантов мало, верни 1-3 строки. Пустой список лучше, чем повтор исходного слова.
      Типичные исправления:
      - "проверил" -> {"synonyms":["осмотрел","протестировал","оценил"]}
      - "исчезает" -> {"synonyms":["пропадает","скрывается","закрывается"]}
      - "показывает" -> {"synonyms":["отображает","выводит","демонстрирует"]}
      - "пишу" -> {"synonyms":["набираю","составляю","записываю"]}
      - "настроил" -> {"synonyms":["наладил","установил","сконфигурировал"]}
      - "откроет" -> {"synonyms":["покажет","выведет","отобразит"]}
      - "подготовлю" -> {"synonyms":["соберу","оформлю","составлю"]}
      - "окно" -> {"synonyms":["панель","окошко","попап"]}
      - "значок" -> {"synonyms":["иконка","символ","кнопка"]}
      - "готовая" -> {"synonyms":["завершенная","собранная","подготовленная"]}
      - "панель" -> {"synonyms":["меню","строка","раздел"]}
      - "доступ" -> {"synonyms":["разрешение","допуск","право"]}
      - "замена" -> {"synonyms":["подстановка","смена","вариант"]}
      - "режим" -> {"synonyms":["настройка","формат","вариант"]}
      - "скорость" -> {"synonyms":["быстрота","темп","оперативность"]}
      - "простые" -> {"synonyms":["обычные","легкие","несложные"]}
      - "редкие" -> {"synonyms":["нечастые","единичные","необычные"]}
      - "репозиторий" -> {"synonyms":["проект","хранилище","каталог"]}
      - "разговорный" -> {"synonyms":["неформальный","просторечный","бытовой"]}
      - "появится" -> {"synonyms":["возникнет","отобразится","покажется"]}
      - "темная" -> {"synonyms":["глубокая","насыщенная","приглушенная"]}
      - "часто" -> {"synonyms":["нередко","регулярно","постоянно"]}
      - "вручную" -> {"synonyms":["самостоятельно","руками","своими силами"]}
      - "напрямую" -> {"synonyms":["непосредственно","прямо","без посредников"]}
      """
      : ""

    let systemInstruction =
      repairAttempt
      ? """
      Ты русскоязычный редактор. Предыдущий ответ уже провалился, потому что повторил исходное слово.
      Твоя задача — вернуть 1-3 русские замены другой лексемы, которые можно прямо вставить вместо выделенного слова.
      Сохрани часть речи, грамматическую форму, стиль и смысл исходного предложения.
      Не возвращай исходное слово, его формы, однокоренные слова, объяснения, markdown, номера или категории.
      Отвечай только JSON-объектом вида {"synonyms":["замена1","замена2"]}.
      """
      : """
      Ты русскоязычный редактор. Твоя задача — составить лидерборд замен для выделенного слова, которые можно прямо вставить в исходное предложение.
      Отвечай только JSON-объектом вида {"synonyms":["..."]}, без пояснений и markdown.

      Внутренне сделай проверку, но не показывай ее:
      1. Определи значение слова в контексте.
      2. Определи часть речи и грамматическую форму.
      3. Определи стиль, тон, уровень формальности и связанные соседние слова.
      4. Проверь, как все предложение звучит после замены.
      5. Удали варианты, которые искажают смысл, ломают сочетаемость, являются опечаточным исправлением, антонимом, другим действием или другой частью речи.
      6. Отсортируй варианты: сначала самые подходящие именно для предложения.

      Жесткие правила:
      - Верни от 1 до 6 реальных русских замен. Лучше 1-3 хорошие замены, чем 6 плохих.
      - Никогда не добивай список повторами исходного слова или почти одинаковыми вариантами.
      - Если выделено одно слово, каждая замена тоже должна быть одним словом.
      - Замена должна быть той же частью речи и подходить к исходному предложению грамматически.
      - Для глагола сохраняй форму: время, лицо, число, род и возвратность, если она есть.
      - Для глагола не возвращай инфинитив, если выделена личная или прошедшая форма.
      - Не возвращай другую форму того же глагола. Нужна другая лексема с близким смыслом.
      - Учитывай стиль, эмоциональную окраску и уровень формальности исходного текста.
      - Не делай нейтральный текст чрезмерно литературным или искусственно красивым.
      - Не предлагай вариант, если он требует менять соседние слова.
      - Не возвращай исходное слово, однокоренные формы и варианты с тем же корнем.
      - Буквы "е" и "ё" считай одной буквой: "веселый" и "весёлый" — это одно и то же исходное слово, не синоним.
      - Не исправляй слово на похожее по буквам. Например, "срал" нельзя заменять на "сжал" или "сжимал".
      - Не продолжай предложение и не отвечай на него.
      - Не возвращай приветствия, клише и бытовые фразы вроде "добрый день" или "добро пожаловать".
      - Если слово грубое, разговорное или обсценное, сохраняй этот смысл. Не цензурируй и не переводь в другое действие.
      - Первый вариант должен быть самым естественным для прямой вставки в предложение.
      - Не возвращай объяснения, markdown, номера или категории.
      - Единственный допустимый формат ответа: {"synonyms":["замена1","замена2"]}.

      Мини-примеры:
      - Для "веселый" хорошие типы ответов: {"synonyms":["радостный","жизнерадостный","забавный"]}. Нельзя: ["весёлый"].
      - Для "хорошо" нужны наречия: {"synonyms":["отлично","прекрасно","замечательно"]}. Нельзя: ["добрый день"].
      - Для "вкусным" форма должна остаться творительным падежом: {"synonyms":["аппетитным","лакомым"]}. Нельзя: ["аппетитный"].
      - Для "классные" форма должна остаться множественной: {"synonyms":["отличные","добротные"]}. Нельзя: ["отличный"].
      - Для "попробуем" нужны личные формы: {"synonyms":["попытаемся","проверим","протестируем"]}. Нельзя: ["попробовать"].
      - Для "переделывал" нужны прошедшие формы: {"synonyms":["исправлял","дорабатывал","перерабатывал"]}. Нельзя: ["переделывать","переделать"].
      - Для "настроил" нужны прошедшие формы другой лексемы: {"synonyms":["наладил","установил"]}. Нельзя: ["настраивал"].
      - Для "откроет" нужны будущие формы другой лексемы: {"synonyms":["покажет","выведет","отобразит"]}. Нельзя: ["откроется"].
      - Для "подготовлю" нужны формы первого лица: {"synonyms":["соберу","оформлю","составлю"]}. Нельзя: ["подготавливаю"].
      - Для "появится" нужны будущие формы другой лексемы: {"synonyms":["возникнет","отобразится"]}. Нельзя: ["появляется"].
      - Для "напрямую" нужны наречия: {"synonyms":["непосредственно","прямо","без посредников"]}. Нельзя: ["прямой"].
      - Для "темная" сохраняй женскую форму прилагательного: {"synonyms":["глубокая","насыщенная","приглушенная"]}. Нельзя: ["темно-розовая"].
      - Для "значок" нужны существительные: {"synonyms":["иконка","символ","кнопка"]}. Нельзя: ["значимый"].
      - Для "готовая" сохраняй женскую форму прилагательного: {"synonyms":["завершенная","собранная","подготовленная"]}. Нельзя: ["готовность"].
      - Для "доступ" нужны существительные без того же корня: {"synonyms":["разрешение","допуск","право"]}. Нельзя: ["доступность"].
      - Для "замена" нужны существительные без того же корня: {"synonyms":["подстановка","смена","вариант"]}. Нельзя: ["заменить"].
      """

    return ChatCompletionRequest(
      model: model.serverModelID,
      messages: [
        ChatMessage(
          role: "system",
          content: systemInstruction
        ),
        ChatMessage(
          role: "user",
          content:
            """
            /no_think
            Выделенное слово: \(selectedText)
            \(contextInstruction)
            \(repairInstruction)
            Верни JSON-объект {"synonyms":[...]} из 1-6 строк, отсортированных от лучшей замены к худшей.
            """
        ),
      ],
      temperature: repairAttempt ? 0.45 : 0.2,
      maxTokens: repairAttempt ? 64 : 80,
      stream: false,
      responseFormat: ChatResponseFormat(type: "json_object")
    )
  }
}

private struct ChatCompletionRequest: Encodable {
  let model: String
  let messages: [ChatMessage]
  let temperature: Double
  let maxTokens: Int
  let stream: Bool
  let responseFormat: ChatResponseFormat

  enum CodingKeys: String, CodingKey {
    case model
    case messages
    case temperature
    case maxTokens = "max_tokens"
    case stream
    case responseFormat = "response_format"
  }
}

private struct ChatResponseFormat: Encodable {
  let type: String
}

private struct ChatMessage: Codable {
  let role: String
  let content: String
}

private struct ChatCompletionResponse: Decodable {
  let choices: [Choice]

  struct Choice: Decodable {
    let message: ChatMessage
  }
}
