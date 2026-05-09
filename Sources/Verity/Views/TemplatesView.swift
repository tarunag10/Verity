import AppKit
import SwiftUI
import VerityCore

struct TemplatesView: View {
    @ObservedObject var store: LibraryStore
    @State private var selectedTemplateID: TemplateID = .invoiceExtraction
    @State private var selectedCustomTemplateID: UUID?
    @State private var selectedDocumentIDs: Set<UUID> = []
    @State private var selectedResultID: UUID?
    @State private var selectedSource: SourceReference?
    @State private var exportMessage: String?
    @State private var newCustomTemplateName = ""

    private var selectedTemplate: TemplateDefinition {
        TemplateEngine.builtInTemplates.first { $0.id == selectedTemplateID } ?? TemplateEngine.builtInTemplates[0]
    }

    private var selectedCustomTemplate: CustomTemplateDefinition? {
        selectedCustomTemplateID.flatMap { id in
            store.customTemplates.first { $0.id == id }
        }
    }

    private var selectedTemplateSummary: String {
        selectedCustomTemplate?.summary ?? selectedTemplate.summary
    }

    private var selectedResult: TemplateRunResult? {
        if let selectedResultID,
           let result = store.templateResults.first(where: { $0.id == selectedResultID }) {
            return result
        }
        return store.templateResults.first
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HSplitView {
                templateList
                    .frame(minWidth: 280, idealWidth: 320)
                resultPane
                    .frame(minWidth: 620)
            }
        }
        .navigationTitle("Templates")
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reusable Workflows")
                    .font(.headline)
                Text(selectedTemplateSummary)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                let result: TemplateRunResult
                if let selectedCustomTemplateID,
                   let customResult = store.runCustomTemplate(selectedCustomTemplateID, documentIDs: selectedDocumentIDs) {
                    result = customResult
                } else {
                    result = store.runTemplate(selectedTemplateID, documentIDs: selectedDocumentIDs)
                }
                selectedResultID = result.id
                selectedSource = nil
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
        List {
            Section("Built In") {
                ForEach(TemplateEngine.builtInTemplates) { template in
                    Button {
                        selectedTemplateID = template.id
                        selectedCustomTemplateID = nil
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selectedTemplateID == template.id ? "tablecells.fill" : "tablecells")
                                .foregroundStyle(.primary)
                                .frame(width: 16)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.name)
                                    .lineLimit(1)
                                Text(template.summary)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }

            Section("Custom") {
                HStack {
                    TextField("New field extractor", text: $newCustomTemplateName)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        let name = newCustomTemplateName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        let template = store.saveCustomTemplate(
                            name: name,
                            summary: "Custom local extraction workflow.",
                            fields: [TemplateField(key: "customField", label: "Custom Field", prompt: "Custom field")]
                        )
                        selectedCustomTemplateID = template.id
                        newCustomTemplateName = ""
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Create custom template")
                    }
                    .disabled(newCustomTemplateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ForEach(store.customTemplates) { template in
                    Button {
                        selectedCustomTemplateID = template.id
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selectedCustomTemplateID == template.id ? "slider.horizontal.3.fill" : "slider.horizontal.3")
                                .foregroundStyle(.primary)
                                .frame(width: 16)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.name)
                                    .lineLimit(1)
                                Text("\(template.fields.count) fields")
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }

            if !store.templateResults.isEmpty {
                Section("Runs") {
                    ForEach(store.templateResults) { result in
                        Button {
                            selectedResultID = result.id
                            selectedSource = nil
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selectedResult?.id == result.id ? "clock.badge.checkmark.fill" : "clock")
                                    .foregroundStyle(.primary)
                                    .frame(width: 16)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(result.templateName)
                                        .lineLimit(1)
                                    Text("\(result.documentNames.count) documents - \(result.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Section("Documents") {
                if store.documents.isEmpty {
                    Text("Import documents to run workflows.")
                        .font(.caption)
                        .foregroundStyle(.primary)
                } else {
                    ForEach(store.documents) { document in
                        Toggle(isOn: documentBinding(document.id)) {
                            Text(document.fileName)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var resultPane: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 0) {
                if let exportMessage {
                    Text(exportMessage)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding([.horizontal, .top])
                }

                if let result = selectedResult {
                    resultHeader(result)
                    Table(result.fields) {
                        TableColumn("Field") { field in
                            Text(field.label)
                        }
                        TableColumn("Value") { field in
                            Text(field.value)
                                .textSelection(.enabled)
                        }
                        TableColumn("Citation") { field in
                            if let source = store.sourceReference(for: field) {
                                Button {
                                    selectedSource = source
                                } label: {
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "quote.bubble")
                                            .foregroundStyle(.primary)
                                        Text(source.snippet)
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .accessibilityLabel("Open citation: \(source.snippet)")
                            } else {
                                Text("Uncited")
                                    .foregroundStyle(.primary)
                            }
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
            .frame(minWidth: 520)

            if let selectedSource {
                DocumentViewerView(source: selectedSource) {
                    self.selectedSource = nil
                }
                .frame(minWidth: 360, idealWidth: 420)
            }
        }
    }

    private func resultHeader(_ result: TemplateRunResult) -> some View {
        let citedFields = result.fields.filter { $0.citation != nil }.count
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.templateName)
                        .font(.headline)
                    Text(result.documentNames.isEmpty ? "All ready documents" : result.documentNames.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                Spacer()
                Text(result.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 10) {
                MetricChip(title: "Fields", value: "\(result.fields.count)", systemImage: "list.bullet.rectangle")
                MetricChip(title: "Cited", value: "\(citedFields)", systemImage: "quote.bubble")
                MetricChip(title: "Documents", value: "\(max(1, result.documentNames.count))", systemImage: "doc.text")
            }
        }
        .padding()
        .accessiblePanel()
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

private struct MetricChip: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(.primary)
            Text(value)
                .font(.caption.weight(.semibold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .accessiblePanel()
        .accessibilityElement(children: .combine)
    }
}
