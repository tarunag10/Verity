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
                        .foregroundStyle(.primary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(readiness.title)
                            .font(.headline)
                        Text(readiness.guidance)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Local AI readiness: \(readiness.title). \(readiness.guidance)")
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
                LabeledContent("Model cache") {
                    Text(store.modelSetupState.isReady ? "Both models cached" : "\(store.modelSetupState.missingModelCount) models pending")
                }
                Toggle("Allow model downloads", isOn: modelDownloadBinding)
                modelSetupChecklist
                Text("MLX models run in process and may be downloaded by the runtime on first use. Deterministic local retrieval remains available as the no-download fallback.")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            Section("Document Processing") {
                LabeledContent("Selectable PDFs, text, Markdown, RTF") {
                    Text("Ready")
                }
                LabeledContent("Scanned PDFs and image OCR") {
                    Text(store.ocrSettings.status == .ready ? "Ready" : "Local OCR adapter needed")
                        .foregroundStyle(.primary)
                }
                Toggle("Enable local OCR adapter", isOn: ocrReadyBinding)
                LabeledContent("OCR adapter") {
                    Text(store.ocrSettings.adapterName)
                }
                Text(store.ocrSettings.guidance)
                    .font(.caption)
                    .foregroundStyle(.primary)
                LabeledContent("Indexed documents") {
                    Text("\(store.documents.filter { $0.status == .ready }.count)")
                }
                LabeledContent("Stored chunks") {
                    Text("\(store.chunks.count)")
                }
            }

            Section("Workflow History") {
                LabeledContent("Collections") {
                    Text("\(store.collections.count)")
                }
                LabeledContent("Custom templates") {
                    Text("\(store.customTemplates.count)")
                }
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

    private var modelDownloadBinding: Binding<Bool> {
        Binding {
            store.modelSetupState.allowsModelDownloads
        } set: { value in
            var state = store.modelSetupState
            state.allowsModelDownloads = value
            store.updateModelSetupState(state)
        }
    }

    private var ocrReadyBinding: Binding<Bool> {
        Binding {
            store.ocrSettings.status == .ready
        } set: { value in
            var settings = store.ocrSettings
            settings.status = value ? .ready : .notConfigured
            store.updateOCRSettings(settings)
        }
    }

    private var modelSetupChecklist: some View {
        VStack(alignment: .leading, spacing: 8) {
            SetupStepRow(
                number: 1,
                title: "Choose local runtime",
                detail: store.modelSettings.modelRuntime,
                isComplete: store.modelSettings.readiness != .unavailable
            )
            SetupStepRow(
                number: 2,
                title: "Allow model downloads",
                detail: store.modelSetupState.allowsModelDownloads ? "Downloads allowed on first use" : "Downloads require approval",
                isComplete: store.modelSetupState.allowsModelDownloads
            )
            SetupStepRow(
                number: 3,
                title: "Cache language and embedding models",
                detail: store.modelSetupState.isReady ? "Both models are marked cached" : "\(store.modelSetupState.missingModelCount) models still need cache confirmation",
                isComplete: store.modelSetupState.isReady
            )
        }
        .padding(.vertical, 4)
    }
}

private struct SetupStepRow: View {
    let number: Int
    let title: String
    let detail: String
    let isComplete: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .stroke(Color.primary, lineWidth: isComplete ? 3 : 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number): \(title). \(detail). \(isComplete ? "Complete" : "Incomplete")")
    }
}
