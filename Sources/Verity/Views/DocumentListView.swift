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
                Button {
                    isFolderImporterPresented = true
                } label: {
                    Label("Folder", systemImage: "folder.badge.plus")
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.green)
                Text("Local-only by default")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.documents.count) documents")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextField("Search passages", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if let importError {
                Text(importError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let progress = store.importProgress {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(importStatusText(progress))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            importTask?.cancel()
                            store.clearImportProgress()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .help("Cancel import")
                    }

                    ProgressView(value: progress.fractionCompleted)
                        .progressViewStyle(.linear)
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
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                Text(pageLabel(result.chunk.pageNumber))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
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
                .foregroundStyle(.secondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.fileName)
                    .lineLimit(1)
                Text("\(document.fileType.uppercased()) - \(statusText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
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
