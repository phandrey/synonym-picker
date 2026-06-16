import Foundation

@MainActor
final class LlamaServerManager {
  enum RuntimeStatus: Equatable {
    case missingRuntime
    case starting
    case runningExternal
    case runningManaged
    case failed(String)

    var modelTileStatus: String {
      switch self {
      case .missingRuntime:
        "Missing"
      case .starting:
        "Starting"
      case .runningExternal:
        "External"
      case .runningManaged:
        "Ready"
      case .failed:
        "Failed"
      }
    }
  }

  private let profile: LocalModelProfile
  private let urlSession: URLSession
  private let modelsEndpoint: URL
  private let executableCandidates: [String]
  private var process: Process?
  private var logHandle: FileHandle?

  init(
    profile: LocalModelProfile = ModelCatalog.defaultProfile,
    urlSession: URLSession = .shared,
    modelsEndpoint: URL = URL(string: "http://127.0.0.1:8080/v1/models")!,
    executableCandidates: [String] = [
      "/opt/homebrew/bin/llama-server",
      "/usr/local/bin/llama-server",
    ]
  ) {
    self.profile = profile
    self.urlSession = urlSession
    self.modelsEndpoint = modelsEndpoint
    self.executableCandidates = executableCandidates
  }

  func startIfNeeded(waitTimeout: TimeInterval = 10) async -> RuntimeStatus {
    if await isServerAvailable() {
      if let process, process.isRunning {
        return .runningManaged
      }

      return .runningExternal
    }

    if let process, process.isRunning {
      return await waitUntilReady(timeout: waitTimeout)
    }

    guard let executableURL = findExecutableURL() else {
      return .missingRuntime
    }

    do {
      try startProcess(executableURL: executableURL)
    } catch {
      return .failed("Could not start llama-server: \(error.localizedDescription)")
    }

    return await waitUntilReady(timeout: waitTimeout)
  }

  func isModelDownloaded() -> Bool {
    cachedModelFileURL() != nil
  }

  func isRuntimeInstalled() -> Bool {
    findExecutableURL() != nil
  }

  func modelDownloadProgress() -> Double {
    if isModelDownloaded() {
      return 1
    }

    guard let expectedDownloadBytes = profile.expectedDownloadBytes,
      expectedDownloadBytes > 0
    else {
      return 0
    }

    let downloadedBytes = modelCacheByteCount()
    guard downloadedBytes > 0 else {
      return 0
    }

    return min(Double(downloadedBytes) / Double(expectedDownloadBytes), 0.99)
  }

  func stop() {
    if let process, process.isRunning {
      process.terminate()
    }

    process = nil
    logHandle?.closeFile()
    logHandle = nil
  }

  private func waitUntilReady(timeout: TimeInterval) async -> RuntimeStatus {
    let deadline = Date().addingTimeInterval(timeout)

    while Date() < deadline {
      if await isServerAvailable() {
        if let process, process.isRunning {
          return .runningManaged
        }

        return .runningExternal
      }

      if let process, !process.isRunning {
        return .failed("llama-server exited before it became ready")
      }

      try? await Task.sleep(nanoseconds: 500_000_000)
    }

    if let process, process.isRunning {
      return .starting
    }

    return .failed("llama-server did not become ready")
  }

  private func isServerAvailable() async -> Bool {
    var request = URLRequest(url: modelsEndpoint)
    request.timeoutInterval = 0.8

    do {
      let (_, response) = try await urlSession.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        return false
      }

      return (200..<300).contains(httpResponse.statusCode)
    } catch {
      return false
    }
  }

  private func findExecutableURL() -> URL? {
    executableCandidates
      .first { FileManager.default.isExecutableFile(atPath: $0) }
      .map { URL(fileURLWithPath: $0) }
  }

  private func startProcess(executableURL: URL) throws {
    let process = Process()
    process.executableURL = executableURL
    process.arguments =
      profile.llamaServerArguments + [
        "--host",
        "127.0.0.1",
        "--port",
        "8080",
      ]
    process.environment = ProcessInfo.processInfo.environment

    let handle = makeLogHandle()
    if let handle {
      process.standardOutput = handle
      process.standardError = handle
      logHandle = handle
    }

    try process.run()
    self.process = process
  }

  private func makeLogHandle() -> FileHandle? {
    guard
      let supportDirectory = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
      ).first
    else {
      return nil
    }

    let appDirectory = supportDirectory.appendingPathComponent(
      "SynonymPicker",
      isDirectory: true
    )
    let logURL = appDirectory.appendingPathComponent("llama-server.log")

    do {
      try FileManager.default.createDirectory(
        at: appDirectory,
        withIntermediateDirectories: true
      )

      if !FileManager.default.fileExists(atPath: logURL.path) {
        FileManager.default.createFile(atPath: logURL.path, contents: nil)
      }

      let handle = try FileHandle(forWritingTo: logURL)
      _ = try? handle.seekToEnd()
      return handle
    } catch {
      return nil
    }
  }

  private func cachedModelFileURL() -> URL? {
    guard let cacheDirectory = modelCacheDirectory() else {
      return nil
    }

    let fileManager = FileManager.default
    guard
      let enumerator = fileManager.enumerator(
        at: cacheDirectory,
        includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
        options: [.skipsHiddenFiles]
      )
    else {
      return nil
    }

    for case let url as URL in enumerator
    where url.pathExtension.lowercased() == "gguf"
      && url.lastPathComponent.localizedCaseInsensitiveContains(profile.quant)
    {
      return url
    }

    return nil
  }

  private func modelCacheByteCount() -> Int64 {
    guard let cacheDirectory = modelCacheDirectory() else {
      return 0
    }

    let fileManager = FileManager.default
    guard
      let enumerator = fileManager.enumerator(
        at: cacheDirectory,
        includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
        options: [.skipsHiddenFiles]
      )
    else {
      return 0
    }

    var total: Int64 = 0
    for case let url as URL in enumerator {
      guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
        values.isRegularFile == true
      else {
        continue
      }

      total += Int64(values.fileSize ?? 0)
    }

    return total
  }

  private func modelCacheDirectory() -> URL? {
    let cacheDirectoryName =
      "models--\(profile.repository.replacingOccurrences(of: "/", with: "--"))"
    return FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".cache", isDirectory: true)
      .appendingPathComponent("huggingface", isDirectory: true)
      .appendingPathComponent("hub", isDirectory: true)
      .appendingPathComponent(cacheDirectoryName, isDirectory: true)
  }
}
