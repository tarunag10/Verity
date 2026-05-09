import SwiftUI
import UniformTypeIdentifiers
import VerityCore

struct DocumentListView: View {
    @ObservedObject var store: LibraryStore
    @State private var isImporterPresented = false
    @State private var isFolderImporterPresented = false
    @State private var searchText = ""
    @State private var importError: String?
    @State private var importTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            header

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                documentList
            } else {
                searchResults
            }
        }
        .navigationTitle("Library")
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf, .plainText, .text, .rtf, .markdown],
            allowsMultipleSelection: true
        ) { result in
            startImport {
                await importFiles(result)
            }
        }
        .fileImporter(
            isPresented: $isFolderImporterPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            startImport {
                await importFolder(result)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Local Library")
                    .font(.headline)
                Spacer()
                Button {
                    isImporterPresented = true
                } label: {
                    Label("Import", systemImage: "tray.and.arrow.down")
                }
                .accessibilityHint("Import local PDF, text, Markdown, or RTF documents.")
                Button {
                    isFolderImporterPresented = true
                } label: {
                    Label("Folder", systemImage: "folder.badge.plus")
                }
                .accessibilityLabel("Import Folder")
                .accessibilityHint("Import supported documents from a local folder.")
            }

            HStack(spacing: 8) {
                AccessibleStatusLabel("Local-only by default", systemImage: "lock.fill")
                    .font(.caption)
                Spacer()
                Text("\(store.documents.count) documents")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            TextField("Search passages", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Search document passages")

            if let importError {
                Text(importError)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Import error: \(importError)")
            }

            if let progress = store.importProgress {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(importStatusText(progress))
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            importTask?.cancel()
                            store.clearImportProgress()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.borderless)
                        .help("Cancel import")
                        .accessibilityLabel("Cancel import")
                        .accessibleMinimumTarget()
                    }

                    ProgressView(value: progress.fractionCompleted)
                        .progressViewStyle(.linear)
                        .accessibilityLabel("Import progress")
                        .accessibilityValue("\(Int(progress.fractionCompleted * 100)) percent")
                }
            }
        }
        .padding()
    }

    private var documentList: some View {
        List(selection: $store.selectedDocumentID) {
            ForEach(store.documents) { document in
                DocumentRow(document: document)
                    .tag(document.id)
                    .contextMenu {
                        Button("Remove", role: .destructive) {
                            store.deleteDocument(id: document.id)
                        }
                    }
            }
        }
    }

    private var searchResults: some View {
        List(store.search(searchText)) { result in
            VStack(alignment: .leading, spacing: 6) {
                Text(result.chunk.documentName)
                    .font(.headline)
                    .lineLimit(1)
                Text(result.snippet)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                Text(pageLabel(result.chunk.pageNumber))
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
        }
    }

    private func importFiles(_ result: Result<[URL], Error>) async {
        do {
            for url in try result.get() {
                try Task.checkCancellation()
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                defer {
                    if didStartAccessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                try await store.importDocument(url)
            }
            importError = nil
        } catch is CancellationError {
            importError = "Import canceled."
        } catch {
            importError = error.localizedDescription
        }
    }

    private func importFolder(_ result: Result<[URL], Error>) async {
        do {
            guard let url = try result.get().first else { return }
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            try await store.importFolder(url)
            importError = nil
        } catch is CancellationError {
            importError = "Import canceled."
        } catch {
            importError = error.localizedDescription
        }
    }

    private func startImport(_ operation: @escaping @MainActor () async -> Void) {
        importTask?.cancel()
        importTask = Task {
            await operation()
            importTask = nil
        }
    }

    private func importStatusText(_ progress: ImportProgress) -> String {
        let current = progress.currentFileName.map { " - \($0)" } ?? ""
        return "Importing \(progress.completed) of \(progress.total)\(current)"
    }

    private func pageLabel(_ page: Int?) -> String {
        page.map { "Page \($0)" } ?? "Document citation"
    }
}

private struct DocumentRow: View {
    let document: DocumentMetadata

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(.primary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.fileName)
                    .lineLimit(1)
                Text("\(document.fileType.uppercased()) - \(statusText)")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(document.fileName), \(document.fileType.uppercased()), \(statusText)")
    }

    private var iconName: String {
        document.fileType == "pdf" ? "doc.richtext" : "doc.plaintext"
    }

    private var statusText: String {
        switch document.status {
        case .imported: "Imported"
        case .indexing: "Indexing"
        case .ready: "Ready"
        case .failed: "Failed"
        case .ocrNeeded: "OCR needed"
        }
    }
}

private extension UTType {
    static var markdown: UTType {
        UTType(filenameExtension: "md") ?? .plainText
    }
}
