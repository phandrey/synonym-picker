import Foundation

struct LocalModelProfile: Equatable, Sendable {
  let id: String
  let displayName: String
  let shortName: String
  let repository: String
  let quant: String
  let approximateSize: String
  let expectedDownloadBytes: Int64?
  let role: String
  let serverModelID: String
  let serverArguments: [String]

  var llamaServerCommand: String {
    (["llama-server"] + llamaServerArguments).joined(separator: " ")
  }

  var llamaServerArguments: [String] {
    ["-hf", "\(repository):\(quant)"] + serverArguments
  }
}

enum ModelCatalog {
  private static let defaultServerArguments = [
    "-ngl", "99",
    "-c", "2048",
  ]

  static let tLite = LocalModelProfile(
    id: "t-lite-it-1.0-q4-k-s",
    displayName: "T-Lite IT 1.0 Q4_K_S",
    shortName: "T-Lite 8B",
    repository: "DefaultDF/T-Lite-It-1.0-Quants-GGUF",
    quant: "Q4_K_S",
    approximateSize: "3.25 GB",
    expectedDownloadBytes: nil,
    role: "Russian Quality",
    serverModelID: "DefaultDF/T-Lite-It-1.0-Quants-GGUF:Q4_K_S",
    serverArguments: defaultServerArguments
  )

  static let qwen25SevenB = LocalModelProfile(
    id: "qwen2.5-7b-instruct-q4-k-m",
    displayName: "Qwen2.5 7B Instruct Q4_K_M",
    shortName: "Qwen2.5 7B",
    repository: "Qwen/Qwen2.5-7B-Instruct-GGUF",
    quant: "Q4_K_M",
    approximateSize: "3.0 GB",
    expectedDownloadBytes: nil,
    role: "Quality",
    serverModelID: "Qwen/Qwen2.5-7B-Instruct-GGUF:Q4_K_M",
    serverArguments: defaultServerArguments
  )

  static let qwen3FourB = LocalModelProfile(
    id: "qwen3-4b-q4-k-m",
    displayName: "Qwen3 4B Q4_K_M",
    shortName: "Qwen3 4B",
    repository: "Qwen/Qwen3-4B-GGUF",
    quant: "Q4_K_M",
    approximateSize: "2.33 GB",
    expectedDownloadBytes: 2_491_323_904,
    role: "Balanced",
    serverModelID: "Qwen/Qwen3-4B-GGUF:Q4_K_M",
    serverArguments: defaultServerArguments
  )

  static let qwen3EightB = LocalModelProfile(
    id: "qwen3-8b-q4-k-m",
    displayName: "Qwen3 8B Q4_K_M",
    shortName: "Qwen3 8B",
    repository: "Qwen/Qwen3-8B-GGUF",
    quant: "Q4_K_M",
    approximateSize: "4.68 GB",
    expectedDownloadBytes: nil,
    role: "Qwen Quality",
    serverModelID: "Qwen/Qwen3-8B-GGUF:Q4_K_M",
    serverArguments: defaultServerArguments
  )

  static let qwen3FastLegacy = LocalModelProfile(
    id: "qwen3-1.7b-q4-k-m",
    displayName: "Qwen3 1.7B Q4_K_M",
    shortName: "Qwen3 1.7B",
    repository: "bartowski/Qwen_Qwen3-1.7B-GGUF",
    quant: "Q4_K_M",
    approximateSize: "1.28 GB",
    expectedDownloadBytes: nil,
    role: "Legacy Fast",
    serverModelID: "bartowski/Qwen_Qwen3-1.7B-GGUF:Q4_K_M",
    serverArguments: defaultServerArguments
  )

  static let available = [qwen3FourB, tLite, qwen25SevenB, qwen3EightB, qwen3FastLegacy]
  static let defaultProfile = qwen3FourB
}
