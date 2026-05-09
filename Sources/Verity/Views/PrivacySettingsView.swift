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
                    Text("Not configured")
                        .foregroundStyle(.primary)
                }
                LabeledContent("Storage") {
                    Text(store.storageDirectory.path(percentEncoded: false))
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
            }

            Section("Local Engine") {
                LabeledContent("Model") {
                    Text(store.modelSettings.retrievalEngine)
                        .foregroundStyle(.primary)
                }
                LabeledContent("Documents indexed") {
                    Text("\(store.documents.filter { $0.status == .ready }.count)")
                }
                LabeledContent("Chunks stored") {
                    Text("\(store.chunks.count)")
                }
            }

            Section("Local Extensions") {
                Text("OCR and semantic model adapters can be added without changing the local-first document library.")
                    .font(.caption)
                    .foregroundStyle(.primary)
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
