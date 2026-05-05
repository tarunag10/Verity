import AppKit
import SwiftUI
import VerityCore

struct TemplatesView: View {
    @ObservedObject var store: LibraryStore
    @State private var selectedTemplateID: TemplateID = .invoiceExtraction
    @State private var selectedDocumentIDs: Set<UUID> = []
    @State private var exportMessage: String?

    private var selectedTemplate: TemplateDefinition {
        TemplateEngine.builtInTemplates.first { $0.id == selectedTemplateID } ?? TemplateEngine.builtInTemplates[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HSplitView {
                templateList
                    .frame(minWidth: 260, idealWidth: 300)
                resultPane
                    .frame(minWidth: 520)
            }
        }
        .navigationTitle("Templates")
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reusable Workflows")
                    .font(.headline)
                Text(selectedTemplate.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                let result = store.runTemplate(selectedTemplateID, documentIDs: selectedDocumentIDs)
                exportMessage = "Created \(result.templateName)"
            } label: {
                Label("Run", systemImage: "play.fill")
            }
            .disabled(store.documents.isEmpty)

            Button {
                writeCSV()
            } label: {
                Label("Export CSV", systemImage: "square.and.arrow.down")
            }
            .disabled(store.templateResults.isEmpty)
        }
        .padding()
    }

    private var templateList: some View {
        List(selection: $selectedTemplateID) {
            Section("Built In") {
                ForEach(TemplateEngine.builtInTemplates) { template in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(template.name)
                            .lineLimit(1)
                        Text("Built-in workflow")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .tag(template.id)
                }
            }

            Section("Documents") {
                ForEach(store.documents) { document in
                    Toggle(isOn: documentBinding(document.id)) {
                        Text(document.fileName)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private var resultPane: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let exportMessage {
                Text(exportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal, .top])
            }

            if let result = store.templateResults.first {
                Table(result.fields) {
                    TableColumn("Field") { field in
                        Text(field.label)
                    }
                    TableColumn("Value") { field in
                        Text(field.value)
                            .textSelection(.enabled)
                    }
                    TableColumn("Citation") { field in
                        Text(field.citation?.snippet ?? "Uncited")
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Run a Template",
                    systemImage: "tablecells",
                    description: Text("Select a template and one or more documents to extract structured fields with citations.")
                )
            }
        }
    }

    private func documentBinding(_ id: UUID) -> Binding<Bool> {
        Binding {
            selectedDocumentIDs.contains(id)
        } set: { isSelected in
            if isSelected {
                selectedDocumentIDs.insert(id)
            } else {
                selectedDocumentIDs.remove(id)
            }
        }
    }

    private func writeCSV() {
        let csv = store.exportTemplateResultsCSV()
        let url = store.storageDirectory.appending(path: "verity-template-results.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportMessage = "Exported \(url.lastPathComponent)"
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } catch {
            exportMessage = error.localizedDescription
        }
    }
}
