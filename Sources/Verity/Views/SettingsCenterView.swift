import SwiftUI
import VerityCore

struct SettingsCenterView: View {
    @ObservedObject var store: LibraryStore

    private var readiness: ModelReadiness {
        store.modelSettings.readiness
    }

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

            Section("Local AI Readiness") {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: readiness.systemImage)
                        .font(.title2)
                        .foregroundStyle(readiness == .ready ? .green : .secondary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(readiness.title)
                            .font(.headline)
                        Text(readiness.guidance)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
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
                        .textSelection(.enabled)
                }
                LabeledContent("Embedding model") {
                    Text(store.modelSettings.embeddingModelIdentifier)
                        .textSelection(.enabled)
                }
                Text("MLX models run in process and may be downloaded by the runtime on first use. Deterministic local retrieval remains available as the no-download fallback.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Document Processing") {
                LabeledContent("Selectable PDFs, text, Markdown, RTF") {
                    Text("Ready")
                }
                LabeledContent("Scanned PDFs and image OCR") {
                    Text("Local OCR adapter needed")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Indexed documents") {
                    Text("\(store.documents.filter { $0.status == .ready }.count)")
                }
                LabeledContent("Stored chunks") {
                    Text("\(store.chunks.count)")
                }
            }

            Section("Workflow History") {
                LabeledContent("Template runs") {
                    Text("\(store.templateResults.count)")
                }
                LabeledContent("Evaluation reports") {
                    Text("\(store.evaluationReports.count)")
                }
            }

            Section("Local Data") {
                LabeledContent("Storage") {
                    Text(store.storageDirectory.path(percentEncoded: false))
                        .font(.caption)
                        .lineLimit(2)
                        .textSelection(.enabled)
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
