import SwiftUI
import VerityCore

struct SettingsCenterView: View {
    @ObservedObject var store: LibraryStore

    var body: some View {
        Form {
            Section("Privacy and Trust") {
                Toggle("Local-only mode", isOn: privacyBinding(\.localOnlyMode))
                Toggle("Telemetry", isOn: privacyBinding(\.telemetryEnabled))
                LabeledContent("Document upload") {
                    Text("Never without explicit user action")
                }
                LabeledContent("Professional advice") {
                    Text("Verity cites sources but does not replace expert review")
                }
            }

            Section("Local AI Engine") {
                LabeledContent("Retrieval") {
                    Text(store.modelSettings.retrievalEngine)
                }
                LabeledContent("Answers") {
                    Text(store.modelSettings.answerEngine)
                }
                LabeledContent("Runtime") {
                    Text(store.modelSettings.modelRuntime)
                }
                LabeledContent("Hardware") {
                    Text(store.modelSettings.hardwareSummary)
                }
                LabeledContent("Language model") {
                    Text(store.modelSettings.languageModelIdentifier)
                }
                LabeledContent("Embedding model") {
                    Text(store.modelSettings.embeddingModelIdentifier)
                }
                Text("The MLX module runs in-process on the Mac and downloads Hugging Face models into the local cache on first use. The existing lexical engine remains available as the no-download fallback.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Document Processing") {
                LabeledContent("Selectable PDFs, text, Markdown, RTF") {
                    Text("Ready")
                }
                LabeledContent("Scanned PDFs and image OCR") {
                    Text("Add a local OCR adapter")
                }
            }

            Section("Local Data") {
                LabeledContent("Storage") {
                    Text(store.storageDirectory.path(percentEncoded: false))
                        .font(.caption)
                        .lineLimit(2)
                }
                LabeledContent("Documents") {
                    Text("\(store.documents.count)")
                }
                LabeledContent("Chunks") {
                    Text("\(store.chunks.count)")
                }
                Button(role: .destructive) {
                    store.deleteAllLocalData()
                } label: {
                    Label("Delete Local Library Data", systemImage: "trash")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("Settings")
    }

    private func privacyBinding(_ keyPath: WritableKeyPath<PrivacySettings, Bool>) -> Binding<Bool> {
        Binding {
            store.privacySettings[keyPath: keyPath]
        } set: { value in
            var settings = store.privacySettings
            settings[keyPath: keyPath] = value
            store.updatePrivacySettings(settings)
        }
    }
}
