import SwiftUI
import VerityCore

struct PrivacySettingsView: View {
    @ObservedObject var store: LibraryStore

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Local-only mode", isOn: settingsBinding(\.localOnlyMode))
                Toggle("Telemetry", isOn: settingsBinding(\.telemetryEnabled))
                LabeledContent("Sync") {
                    Text(store.privacySettings.syncEnabled ? "Enabled" : "Off by default")
                        .foregroundStyle(store.privacySettings.syncEnabled ? .orange : .secondary)
                }
                LabeledContent("Storage") {
                    Text(store.storageDirectory.path(percentEncoded: false))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Section("Local Engine") {
                LabeledContent("Model") {
                    Text(store.privacySettings.modelName)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Documents indexed") {
                    Text("\(store.documents.filter { $0.status == .ready }.count)")
                }
                LabeledContent("Chunks stored") {
                    Text("\(store.chunks.count)")
                }
            }

            Section("Pro Extension Points") {
                Toggle("OCR for scanned documents", isOn: settingsBinding(\.ocrEnabled))
                    .disabled(true)
                Toggle("Encrypted sync", isOn: settingsBinding(\.syncEnabled))
                    .disabled(true)
                Text("OCR, sync, templates, licensing, and MLX model management are wired as explicit product surfaces for the next implementation phase.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("Privacy")
    }

    private func settingsBinding(_ keyPath: WritableKeyPath<PrivacySettings, Bool>) -> Binding<Bool> {
        Binding {
            store.privacySettings[keyPath: keyPath]
        } set: { value in
            var settings = store.privacySettings
            settings[keyPath: keyPath] = value
            store.updatePrivacySettings(settings)
        }
    }
}
