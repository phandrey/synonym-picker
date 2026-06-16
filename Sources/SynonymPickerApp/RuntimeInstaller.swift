import AppKit

@MainActor
final class RuntimeInstaller {
  enum InstallResult: Equatable {
    case started
    case cancelled
    case commandCopied
    case homebrewMissing
    case failed(String)
  }

  private let brewCandidates = [
    "/opt/homebrew/bin/brew",
    "/usr/local/bin/brew",
  ]

  func promptAndStartInstall() -> InstallResult {
    guard let brewURL = findBrewURL() else {
      return promptForHomebrewInstall()
    }

    let alert = NSAlert()
    alert.alertStyle = .informational
    alert.messageText = "Install llama.cpp?"
    alert.informativeText =
      """
      Synonym Picker needs llama.cpp to run the local Qwen model.

      The app will open Terminal and run:
      brew install llama.cpp

      After that, Synonym Picker will continue the model download automatically.
      """
    alert.addButton(withTitle: "Install llama.cpp")
    alert.addButton(withTitle: "Copy Command")
    alert.addButton(withTitle: "Cancel")

    switch alert.runModal() {
    case .alertFirstButtonReturn:
      return startTerminalInstall(brewURL: brewURL)
    case .alertSecondButtonReturn:
      copyToPasteboard("brew install llama.cpp")
      return .commandCopied
    default:
      return .cancelled
    }
  }

  private func promptForHomebrewInstall() -> InstallResult {
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = "Homebrew is required"
    alert.informativeText =
      """
      Synonym Picker can install llama.cpp through Homebrew, but Homebrew was not found on this Mac.

      Install Homebrew first, then click the model download row again.
      """
    alert.addButton(withTitle: "Open brew.sh")
    alert.addButton(withTitle: "Copy Homebrew Command")
    alert.addButton(withTitle: "Cancel")

    switch alert.runModal() {
    case .alertFirstButtonReturn:
      if let url = URL(string: "https://brew.sh") {
        NSWorkspace.shared.open(url)
      }
      return .homebrewMissing
    case .alertSecondButtonReturn:
      copyToPasteboard(
        #"/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)""#
      )
      return .commandCopied
    default:
      return .cancelled
    }
  }

  private func startTerminalInstall(brewURL: URL) -> InstallResult {
    do {
      let scriptURL = try makeInstallScript(brewURL: brewURL)
      guard NSWorkspace.shared.open(scriptURL) else {
        return .failed("Could not open Terminal installer")
      }

      return .started
    } catch {
      return .failed("Could not create installer script: \(error.localizedDescription)")
    }
  }

  private func makeInstallScript(brewURL: URL) throws -> URL {
    guard
      let supportDirectory = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
      ).first
    else {
      throw CocoaError(.fileNoSuchFile)
    }

    let appDirectory = supportDirectory.appendingPathComponent(
      "SynonymPicker",
      isDirectory: true
    )
    try FileManager.default.createDirectory(
      at: appDirectory,
      withIntermediateDirectories: true
    )

    let scriptURL = appDirectory.appendingPathComponent(
      "install-llama-cpp.command"
    )
    let script =
      """
      #!/bin/zsh

      echo "Synonym Picker runtime installer"
      echo "Installing llama.cpp with Homebrew..."
      echo ""
      "\(brewURL.path)" install llama.cpp
      status=$?
      echo ""
      if [ "$status" -eq 0 ]; then
        echo "llama.cpp is installed."
        echo "Return to Synonym Picker. The Qwen model download should continue automatically."
      else
        echo "llama.cpp installation failed with exit code $status."
        echo "Fix the Homebrew error above, then click the model row in Synonym Picker again."
      fi
      echo ""
      read -r "?Press Return to close this window..."
      """

    try script.write(to: scriptURL, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes(
      [.posixPermissions: 0o755],
      ofItemAtPath: scriptURL.path
    )

    return scriptURL
  }

  private func findBrewURL() -> URL? {
    brewCandidates
      .first { FileManager.default.isExecutableFile(atPath: $0) }
      .map { URL(fileURLWithPath: $0) }
  }

  private func copyToPasteboard(_ command: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(command, forType: .string)
  }
}
