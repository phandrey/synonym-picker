import SwiftUI

struct SettingsView: View {
  @ObservedObject var appState: AppState

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      header

      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: 10),
          GridItem(.flexible(), spacing: 10),
        ],
        spacing: 10
      ) {
        SettingsTile(
          title: "Hotkey",
          subtitle: appState.hotkeyDisplay,
          systemImage: "keyboard",
          status: appState.hotkeyStatus,
          isActive: appState.isRecordingHotkey,
          action: {
            appState.startHotkeyRecording()
          }
        )

        SettingsTile(
          title: "Model",
          subtitle: appState.modelSubtitle,
          systemImage: "cpu",
          status: appState.modelStatus
        )

        SettingsTile(
          title: "Permissions",
          subtitle: appState.permissionSubtitle,
          systemImage: "lock.shield",
          status: appState.permissionStatus,
          isActive: !appState.hasAccessibilityPermission,
          action: {
            appState.requestAccessibilityPermission()
          }
        )

        SettingsTile(
          title: "Local",
          subtitle: "Private MVP",
          systemImage: "internaldrive",
          status: "Ready"
        )
      }
    }
    .padding(14)
    .frame(width: 336)
    .background {
      RoundedRectangle(cornerRadius: 14)
        .fill(.ultraThinMaterial)
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(.white.opacity(0.16), lineWidth: 1)
        }
    }
  }

  private var header: some View {
    HStack(spacing: 10) {
      Image(systemName: "sparkles")
        .font(.title3)
        .symbolRenderingMode(.hierarchical)

      VStack(alignment: .leading, spacing: 2) {
        Text("Synonym Picker")
          .font(.system(.title3, weight: .semibold))
        Text("Local contextual synonyms for macOS")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Text("MVP")
        .font(.system(.caption, weight: .semibold))
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
  }
}

private struct SettingsTile: View {
  let title: String
  let subtitle: String
  let systemImage: String
  let status: String
  var isActive = false
  var action: (() -> Void)?

  var body: some View {
    Button {
      action?()
    } label: {
      VStack(spacing: 7) {
        Image(systemName: systemImage)
          .font(.system(size: 25, weight: .regular))
          .symbolRenderingMode(.hierarchical)
          .frame(height: 29)

        Text(title)
          .font(.system(.body, weight: .semibold))
          .lineLimit(1)

        Text(subtitle)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)

        Text(status)
          .font(.caption2)
          .foregroundStyle(isActive ? .primary : .secondary)
          .lineLimit(1)
      }
    }
    .buttonStyle(.plain)
    .disabled(action == nil)
    .frame(maxWidth: .infinity)
    .frame(height: 104)
    .background {
      RoundedRectangle(cornerRadius: 10)
        .fill(.ultraThinMaterial)
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(isActive ? .white.opacity(0.32) : .white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 5, x: 0, y: 2)
    }
  }
}
