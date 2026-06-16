#!/usr/bin/env node
import fs from "node:fs/promises";
import { performance } from "node:perf_hooks";

const endpoint =
  process.env.SYNONYM_PICKER_ENDPOINT ??
  "http://127.0.0.1:8080/v1/chat/completions";
const model =
  process.env.SYNONYM_PICKER_MODEL ??
  "Qwen/Qwen3-4B-GGUF:Q4_K_M";
const fixturePath =
  process.argv[2] ?? new URL("./fixtures/russian-synonym-benchmark.json", import.meta.url);

const cases = JSON.parse(await fs.readFile(fixturePath, "utf8"));

const adjectiveEndingGroups = [
  {
    endings: ["ый", "ий", "ой"],
    hardEnding: "ый",
    softEnding: "ий",
    velarEnding: "ий",
    isNominativeMasculine: true,
  },
  { endings: ["ая", "яя"], hardEnding: "ая", softEnding: "яя", velarEnding: "ая" },
  { endings: ["ое", "ее"], hardEnding: "ое", softEnding: "ее", velarEnding: "ое" },
  { endings: ["ые", "ие"], hardEnding: "ые", softEnding: "ие", velarEnding: "ие" },
  { endings: ["ого", "его"], hardEnding: "ого", softEnding: "его", velarEnding: "ого" },
  { endings: ["ому", "ему"], hardEnding: "ому", softEnding: "ему", velarEnding: "ому" },
  { endings: ["ым", "им"], hardEnding: "ым", softEnding: "им", velarEnding: "им" },
  { endings: ["ом", "ем"], hardEnding: "ом", softEnding: "ем", velarEnding: "ом" },
  { endings: ["ых", "их"], hardEnding: "ых", softEnding: "их", velarEnding: "их" },
  { endings: ["ую", "юю"], hardEnding: "ую", softEnding: "юю", velarEnding: "ую" },
  { endings: ["ыми", "ими"], hardEnding: "ыми", softEnding: "ими", velarEnding: "ими" },
];
const knownAdverbWords = new Set(["вручную", "напрямую"]);
const knownNonAdjectiveNounSuffixes = ["арий", "ерий", "орий", "торий"];

for (const testCase of cases) {
  const startedAt = performance.now();
  let attempts = 1;
  let { content, status } = await requestCompletion(testCase, false, 6500);

  const elapsedMs = Math.round(performance.now() - startedAt);
  let raw = extractCandidates(content);
  let filtered = filterCandidates(raw, testCase.selectedText);
  let finalElapsedMs = elapsedMs;
  let firstRawContent = content;

  if (status === "ok" && filtered.length === 0) {
    attempts = 2;
    const repair = await requestCompletion(testCase, true, 4500);
    finalElapsedMs = Math.round(performance.now() - startedAt);
    content = repair.content;
    raw = extractCandidates(content);
    filtered = filterCandidates(raw, testCase.selectedText);
    status = repair.status === "ok"
      ? (filtered.length > 0 ? "repair_ok" : "empty")
      : repair.status;
  }

  console.log(JSON.stringify({
    selectedText: testCase.selectedText,
    status,
    elapsedMs: finalElapsedMs,
    attempts,
    firstRawContent: attempts > 1 ? firstRawContent : undefined,
    rawContent: content,
    raw,
    filtered,
  }));
}

async function requestCompletion(testCase, repairAttempt, timeoutMs) {
  try {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(makeRequest(testCase, repairAttempt)),
      signal: AbortSignal.timeout(timeoutMs),
    });

    if (!response.ok) {
      return { status: `http_${response.status}`, content: await response.text() };
    }

    const payload = await response.json();
    return { status: "ok", content: payload?.choices?.[0]?.message?.content ?? "" };
  } catch (error) {
    return { status: "error", content: error?.message ?? String(error) };
  }
}

function makeRequest(testCase, repairAttempt = false) {
  return {
    model,
    messages: [
      {
        role: "system",
        content: systemPrompt(repairAttempt),
      },
      {
        role: "user",
        content: [
          "/no_think",
          `Выделенное слово: ${testCase.selectedText}`,
          `Короткий контекст: ${testCase.context}`,
          `Предложение: ${testCase.context}`,
          "Задача: заменить только выделенное слово в этом предложении.",
          repairAttempt
            ? `Первый ответ был полностью отфильтрован: модель повторила исходное слово или дала ту же лексему.
Верни только новые лексемы. Запрещено возвращать "${testCase.selectedText}", его формы, однокоренные слова и фразы с ним.
Если вариантов мало, верни 1-3 строки. Пустой список лучше, чем повтор исходного слова.`
            : "",
          repairAttempt
            ? `Типичные исправления:
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
- "напрямую" -> {"synonyms":["непосредственно","прямо","без посредников"]}`
            : "",
          "Верни JSON-объект {\"synonyms\":[...]} из 1-6 строк.",
        ].filter(Boolean).join("\n"),
      },
    ],
    temperature: repairAttempt ? 0.45 : 0.2,
    max_tokens: repairAttempt ? 64 : 80,
    stream: false,
    response_format: { type: "json_object" },
  };
}

function systemPrompt(repairAttempt) {
  if (repairAttempt) {
    return [
      "Ты русскоязычный редактор. Предыдущий ответ уже провалился, потому что повторил исходное слово.",
      "Твоя задача — вернуть 1-3 русские замены другой лексемы, которые можно прямо вставить вместо выделенного слова.",
      "Сохрани часть речи, грамматическую форму, стиль и смысл исходного предложения.",
      "Не возвращай исходное слово, его формы, однокоренные слова, объяснения, markdown, номера или категории.",
      "Отвечай только JSON-объектом вида {\"synonyms\":[\"замена1\",\"замена2\"]}.",
    ].join("\n");
  }

  return [
    "Ты русскоязычный редактор. Твоя задача — составить лидерборд замен для выделенного слова, которые можно прямо вставить в исходное предложение.",
    "Отвечай только JSON-объектом вида {\"synonyms\":[\"...\"]}, без пояснений и markdown.",
    "",
    "Внутренне сделай проверку, но не показывай ее:",
    "1. Определи значение слова в контексте.",
    "2. Определи часть речи и грамматическую форму.",
    "3. Определи стиль, тон, уровень формальности и связанные соседние слова.",
    "4. Проверь, как все предложение звучит после замены.",
    "5. Удали варианты, которые искажают смысл, ломают сочетаемость, являются опечаточным исправлением, антонимом, другим действием или другой частью речи.",
    "6. Отсортируй варианты: сначала самые подходящие именно для предложения.",
    "",
    "Жесткие правила:",
    "- Верни от 1 до 6 реальных русских замен. Лучше 1-3 хорошие замены, чем 6 плохих.",
    "- Никогда не добивай список повторами исходного слова или почти одинаковыми вариантами.",
    "- Если выделено одно слово, каждая замена тоже должна быть одним словом.",
    "- Замена должна быть той же частью речи и подходить к исходному предложению грамматически.",
    "- Для глагола сохраняй форму: время, лицо, число, род и возвратность, если она есть.",
    "- Для глагола не возвращай инфинитив, если выделена личная или прошедшая форма.",
    "- Не возвращай другую форму того же глагола. Нужна другая лексема с близким смыслом.",
    "- Учитывай стиль, эмоциональную окраску и уровень формальности исходного текста.",
    "- Не делай нейтральный текст чрезмерно литературным или искусственно красивым.",
    "- Не предлагай вариант, если он требует менять соседние слова.",
    "- Не возвращай исходное слово, однокоренные формы и варианты с тем же корнем.",
    "- Буквы \"е\" и \"ё\" считай одной буквой: \"веселый\" и \"весёлый\" — это одно и то же исходное слово, не синоним.",
    "- Не исправляй слово на похожее по буквам. Например, \"срал\" нельзя заменять на \"сжал\" или \"сжимал\".",
    "- Не продолжай предложение и не отвечай на него.",
    "- Не возвращай приветствия, клише и бытовые фразы вроде \"добрый день\" или \"добро пожаловать\".",
    "- Если слово грубое, разговорное или обсценное, сохраняй этот смысл. Не цензурируй и не переводь в другое действие.",
    "- Первый вариант должен быть самым естественным для прямой вставки в предложение.",
    "- Не возвращай объяснения, markdown, номера или категории.",
    "- Единственный допустимый формат ответа: {\"synonyms\":[\"замена1\",\"замена2\"]}.",
    "",
    "Мини-примеры:",
    "- Для \"веселый\" хорошие типы ответов: {\"synonyms\":[\"радостный\",\"жизнерадостный\",\"забавный\"]}. Нельзя: [\"весёлый\"].",
    "- Для \"хорошо\" нужны наречия: {\"synonyms\":[\"отлично\",\"прекрасно\",\"замечательно\"]}. Нельзя: [\"добрый день\"].",
    "- Для \"вкусным\" форма должна остаться творительным падежом: {\"synonyms\":[\"аппетитным\",\"лакомым\"]}. Нельзя: [\"аппетитный\"].",
    "- Для \"классные\" форма должна остаться множественной: {\"synonyms\":[\"отличные\",\"добротные\"]}. Нельзя: [\"отличный\"].",
    "- Для \"попробуем\" нужны личные формы: {\"synonyms\":[\"попытаемся\",\"проверим\",\"протестируем\"]}. Нельзя: [\"попробовать\"].",
    "- Для \"переделывал\" нужны прошедшие формы: {\"synonyms\":[\"исправлял\",\"дорабатывал\",\"перерабатывал\"]}. Нельзя: [\"переделывать\",\"переделать\"].",
    "- Для \"настроил\" нужны прошедшие формы другой лексемы: {\"synonyms\":[\"наладил\",\"установил\"]}. Нельзя: [\"настраивал\"].",
    "- Для \"откроет\" нужны будущие формы другой лексемы: {\"synonyms\":[\"покажет\",\"выведет\",\"отобразит\"]}. Нельзя: [\"откроется\"].",
    "- Для \"подготовлю\" нужны формы первого лица: {\"synonyms\":[\"соберу\",\"оформлю\",\"составлю\"]}. Нельзя: [\"подготавливаю\"].",
    "- Для \"появится\" нужны будущие формы другой лексемы: {\"synonyms\":[\"возникнет\",\"отобразится\"]}. Нельзя: [\"появляется\"].",
    "- Для \"напрямую\" нужны наречия: {\"synonyms\":[\"непосредственно\",\"прямо\",\"без посредников\"]}. Нельзя: [\"прямой\"].",
    "- Для \"темная\" сохраняй женскую форму прилагательного: {\"synonyms\":[\"глубокая\",\"насыщенная\",\"приглушенная\"]}. Нельзя: [\"темно-розовая\"].",
    "- Для \"значок\" нужны существительные: {\"synonyms\":[\"иконка\",\"символ\",\"кнопка\"]}. Нельзя: [\"значимый\"].",
    "- Для \"готовая\" сохраняй женскую форму прилагательного: {\"synonyms\":[\"завершенная\",\"собранная\",\"подготовленная\"]}. Нельзя: [\"готовность\"].",
    "- Для \"доступ\" нужны существительные без того же корня: {\"synonyms\":[\"разрешение\",\"допуск\",\"право\"]}. Нельзя: [\"доступность\"].",
    "- Для \"замена\" нужны существительные без того же корня: {\"synonyms\":[\"подстановка\",\"смена\",\"вариант\"]}. Нельзя: [\"заменить\"].",
  ].join("\n");
}

function extractCandidates(content) {
  const trimmed = String(content ?? "").trim();
  if (!trimmed) return [];

  const parsed = parseJsonCandidates(trimmed);
  if (parsed.length > 0) return parsed;

  const objectMatch = trimmed.match(/\{[\s\S]*\}/);
  if (objectMatch) {
    const objectCandidates = parseJsonCandidates(objectMatch[0]);
    if (objectCandidates.length > 0) return objectCandidates;
  }

  const arrayMatch = trimmed.match(/\[[\s\S]*\]/);
  if (arrayMatch) {
    const arrayCandidates = parseJsonCandidates(arrayMatch[0]);
    if (arrayCandidates.length > 0) return arrayCandidates;
  }

  return trimmed
    .split(/\r?\n|,|;/)
    .map(cleanCandidate)
    .filter(Boolean);
}

function parseJsonCandidates(value) {
  try {
    const parsed = JSON.parse(value);
    if (Array.isArray(parsed)) return parsed.map(candidateText).filter(Boolean);

    const list =
      parsed.synonyms ??
      parsed.variants ??
      parsed.replacements ??
      parsed["синонимы"] ??
      parsed["варианты"] ??
      parsed["замены"];

    if (Array.isArray(list)) return list.map(candidateText).filter(Boolean);
  } catch {
    return [];
  }

  return [];
}

function candidateText(value) {
  if (typeof value === "string") return cleanCandidate(value);
  if (!value || typeof value !== "object") return "";

  return cleanCandidate(
    value.word ??
      value.synonym ??
      value.variant ??
      value.replacement ??
      value["слово"] ??
      value["синоним"] ??
      value["замена"] ??
      ""
  );
}

function filterCandidates(candidates, source) {
  const sourceKey = comparisonKey(source);
  const sourceLooksCyrillic = containsCyrillic(source);
  const sourceLooksAdverb = isLikelyShortAdverb(source);
  const sourceWordCount = wordCount(source);
  const seen = new Set();
  const result = [];

  for (const candidate of candidates) {
    const cleaned = adaptGrammaticalShape(cleanCandidate(candidate), source);
    const key = comparisonKey(cleaned);
    if (!cleaned || key === sourceKey || seen.has(key)) continue;
    if (!/^[\p{L}\s-]+$/u.test(cleaned)) continue;
    if (sourceWordCount === 1 && !sourceLooksAdverb && wordCount(cleaned) !== 1) continue;
    if (sourceWordCount === 1 && sourceLooksAdverb && wordCount(cleaned) > 3) continue;
    if (sourceLooksCyrillic && (containsLatin(cleaned) || containsCJK(cleaned))) continue;
    if (containsSourceWord(cleaned, source)) continue;
    if (isNearDuplicate(cleaned, source)) continue;
    if (!isGrammaticallyCompatible(cleaned, source)) continue;
    if (sourceLooksAdverb && looksLikeAdjective(cleaned)) continue;
    if (cleaned.split(/\s+/).length > 3) continue;

    seen.add(key);
    result.push(cleaned);
  }

  return result;
}

function cleanCandidate(value) {
  return String(value ?? "")
    .trim()
    .replace(/^[-*\d.)\s]+/, "")
    .replace(/^["'`.,;:[\](){}]+|["'`.,;:[\](){}]+$/g, "")
    .trim();
}

function comparisonKey(value) {
  return String(value ?? "").toLowerCase().replaceAll("ё", "е");
}

function containsCyrillic(value) {
  return /[\u0400-\u052f]/u.test(String(value ?? ""));
}

function containsLatin(value) {
  return /[A-Za-z]/u.test(String(value ?? ""));
}

function containsCJK(value) {
  return /[\u3400-\u9fff]/u.test(String(value ?? ""));
}

function containsSourceWord(value, source) {
  const sourceKey = comparisonKey(source);
  if (!sourceKey) return false;

  return comparisonKey(value).split(/[^\p{L}]+/u).filter(Boolean).includes(sourceKey);
}

function isLikelyShortAdverb(value) {
  const word = firstWord(value);
  if (knownAdverbWords.has(word)) return true;
  if (word.length < 4) return false;
  if (adjectiveEndingGroup(word)) return false;

  return word.endsWith("о") || word.endsWith("е");
}

function looksLikeAdjective(value) {
  return Boolean(adjectiveEndingGroup(value));
}

function firstWord(value) {
  return comparisonKey(value).split(/[^\p{L}]+/u).filter(Boolean)[0] ?? "";
}

function wordCount(value) {
  return String(value ?? "").trim().split(/\s+/).filter(Boolean).length;
}

function isNearDuplicate(value, source) {
  const valueVerbStem = verbLexemeStem(value);
  const sourceVerbStem = verbLexemeStem(source);
  if (
    valueVerbStem &&
    sourceVerbStem &&
    valueVerbStem.length >= 4 &&
    sourceVerbStem.length >= 4 &&
    valueVerbStem === sourceVerbStem
  ) {
    return true;
  }

  const normalizedValue = stemCandidate(value);
  const normalizedSource = stemCandidate(source);
  if (normalizedValue.length < 5 || normalizedSource.length < 5) return false;

  return normalizedValue.startsWith(normalizedSource) || normalizedSource.startsWith(normalizedValue);
}

function stemCandidate(value) {
  const word = firstWord(value);
  return stripCommonRussianSuffix(word);
}

function isGrammaticallyCompatible(value, source) {
  const sourceStrongVerbShape = strongVerbShape(source);
  if (sourceStrongVerbShape) return verbShape(value) === sourceStrongVerbShape;

  if (isLikelyShortAdverb(source)) return !looksLikeAdjective(firstWord(value));

  const sourceEndingGroup = adjectiveEndingGroup(source);
  if (!sourceEndingGroup) {
    const sourceVerbShape = verbShape(source);
    return sourceVerbShape ? verbShape(value) === sourceVerbShape : verbShape(value) === null;
  }

  const valueWord = firstWord(value);
  return sourceEndingGroup.endings.some((ending) => valueWord.endsWith(ending));
}

function strongVerbShape(value) {
  const word = firstWord(value);
  if (word.length < 4) return null;

  if (word.endsWith("ость")) return null;

  if (["ться", "тись", "ть", "ти", "чь"].some((suffix) => word.endsWith(suffix))) {
    return "infinitive";
  }

  if (word.endsWith("лись")) return "pastPlural";
  if (word.endsWith("лась")) return "pastFeminine";
  if (word.endsWith("лся")) return "pastMasculine";
  if (["ывали", "ивали", "али", "яли", "или", "ели"].some((suffix) => word.endsWith(suffix))) {
    return "pastPlural";
  }
  if (
    ["ится", "ется", "утся", "ются"].some((suffix) => word.endsWith(suffix)) ||
    (word.endsWith("нет") && word.length >= 7)
  ) {
    return "finite";
  }
  if (["ывала", "ивала", "ала", "яла", "ила", "ела"].some((suffix) => word.endsWith(suffix))) {
    return "pastFeminine";
  }
  if (["ывал", "ивал", "ал", "ял", "ил", "ел"].some((suffix) => word.endsWith(suffix))) {
    return "pastMasculine";
  }
  if (
    [
      "уемся", "аемся", "яемся", "емся", "имся",
      "ируем", "уем", "аем", "яем", "еем",
    ].some((suffix) => word.endsWith(suffix))
  ) {
    return "firstPersonPlural";
  }

  return null;
}

function verbShape(value) {
  const word = firstWord(value);
  return strongVerbShape(value) ?? (
    word.length >= 6 && ["ем", "ём", "им"].some((suffix) => word.endsWith(suffix))
      ? "firstPersonPlural"
      : null
  );
}

function verbLexemeStem(value) {
  let word = firstWord(value);
  if (word.length < 5) return null;

  if (word.endsWith("ся") || word.endsWith("сь")) word = word.slice(0, -2);

  const suffixes = [
    "ываться", "иваться", "ывались", "ивались", "ывалась", "ивалась", "ывался", "ивался",
    "ывать", "ивать", "овать", "евать", "ались", "ялись", "ились", "елись", "алась",
    "ялась", "илась", "елась", "ался", "ялся", "ился", "елся", "аем", "яем", "еем",
    "уем", "ает", "яет", "еет", "ует", "ит", "ет", "ут", "ют", "ывали", "ивали",
    "ала", "яла", "ила", "ела", "али", "яли", "или", "ели", "ать", "ять", "еть", "ить",
    "уть", "ться", "тись", "ывал", "ивал", "ал", "ял", "ил", "ел", "ем", "ём", "им", "ти",
    "ть",
  ];

  for (const suffix of suffixes) {
    if (word.endsWith(suffix) && word.length - suffix.length >= 4) {
      return canonicalVerbStem(word.slice(0, -suffix.length));
    }
  }

  return null;
}

function canonicalVerbStem(value) {
  return value.endsWith("л") && value.length >= 5 ? value.slice(0, -1) : value;
}

function adaptGrammaticalShape(value, source) {
  if (value.includes(" ")) return value;

  const sourceEndingGroup = adjectiveEndingGroup(source);
  if (!sourceEndingGroup || sourceEndingGroup.isNominativeMasculine) return value;

  const base = adjectiveBase(value);
  if (!base) return value;

  return base.stem + sourceEndingGroup[`${base.style}Ending`];
}

function adjectiveBase(value) {
  const word = firstWord(value);
  if (word.endsWith("ий")) {
    const stem = word.slice(0, -"ий".length);
    if (["г", "к", "х"].some((ending) => stem.endsWith(ending)) && stem.length >= 3) {
      return { stem, style: "velar" };
    }
  }

  const forms = [
    ["ий", "soft"],
    ["ый", "hard"],
    ["ой", "hard"],
  ];

  for (const [suffix, style] of forms) {
    if (word.endsWith(suffix) && word.length - suffix.length >= 3) {
      return { stem: word.slice(0, -suffix.length), style };
    }
  }

  return null;
}

function adjectiveEndingGroup(value) {
  const word = firstWord(value);
  if (knownAdverbWords.has(word)) return null;
  if (knownNonAdjectiveNounSuffixes.some((suffix) => word.endsWith(suffix))) return null;

  return adjectiveEndingGroups.find((group) =>
    group.endings.some((ending) => word.endsWith(ending) && hasPlausibleAdjectiveStem(word, ending))
  ) ?? null;
}

function hasPlausibleAdjectiveStem(word, ending) {
  const stemLength = word.length - ending.length;
  if (["ым", "им", "ом", "ем"].includes(ending)) return stemLength >= 4;

  return stemLength >= 3;
}

function stripCommonRussianSuffix(value) {
  const suffixes = [
    "иями", "ями", "ого", "ему", "ыми", "ими", "ыми", "ая", "яя", "ое", "ее", "ий", "ый",
    "ой", "ую", "юю", "ая", "яя", "ым", "им", "ом", "ем", "ых", "их", "ые", "ие", "о",
    "е", "а", "я", "ы", "и",
  ];

  for (const suffix of suffixes) {
    if (value.endsWith(suffix) && value.length - suffix.length >= 4) {
      return value.slice(0, -suffix.length);
    }
  }

  return value;
}
