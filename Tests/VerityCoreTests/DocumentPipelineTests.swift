import Foundation
import Testing
@testable import VerityCore

@Suite("Document pipeline")
struct DocumentPipelineTests {
    @Test("parses Markdown files with metadata")
    func parsesMarkdownFileWithMetadata() async throws {
        let fileURL = try TemporaryFiles.write(
            name: "contract.md",
            contents: """
            # Service Agreement

            The agreement renews on June 30 and includes a 30 day termination notice.
            """
        )

        let parsed = try DocumentParser().parse(fileURL: fileURL)

        #expect(parsed.metadata.fileName == "contract.md")
        #expect(parsed.metadata.fileType == "md")
        #expect(parsed.pages.count == 1)
        #expect(parsed.pages[0].pageNumber == 1)
        #expect(parsed.textQuality == .selectableText)
        #expect(parsed.status == .ready)
    }

    @Test("chunks preserve page references")
    func chunksPreservePageReferences() throws {
        let metadata = DocumentMetadata(fileName: "manual.txt", fileURL: URL(filePath: "/tmp/manual.txt"), fileType: "txt")
        let parsed = ParsedDocument(
            metadata: metadata,
            pages: [
                ParsedPage(pageNumber: 3, text: "Reset the router by holding the rear button for ten seconds. Wait for the status light to turn green.")
            ],
            textQuality: .selectableText,
            status: .ready
        )

        let chunks = DocumentChunker(targetWordCount: 8).chunk(parsed)

        #expect(chunks.isEmpty == false)
        #expect(chunks.allSatisfy { $0.documentID == metadata.id })
        #expect(chunks.allSatisfy { $0.pageNumber == 3 })
        #expect(chunks[0].text.contains("Reset the router"))
    }

    @Test("search ranks relevant chunks first")
    func searchRanksRelevantChunksFirst() throws {
        let contract = DocumentMetadata(fileName: "contract.txt", fileURL: URL(filePath: "/tmp/contract.txt"), fileType: "txt")
        let recipe = DocumentMetadata(fileName: "recipe.txt", fileURL: URL(filePath: "/tmp/recipe.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: recipe.id, documentName: recipe.fileName, pageNumber: 1, text: "Whisk eggs with flour and milk."),
            DocumentChunk(documentID: contract.id, documentName: contract.fileName, pageNumber: 2, text: "The termination clause requires thirty days written notice.")
        ]

        let results = LocalRAGEngine().search(query: "termination notice", chunks: chunks, limit: 3)

        #expect(results.first?.chunk.documentID == contract.id)
        #expect(results.first?.score ?? 0 > 0)
    }

    @Test("answers questions with citations")
    func answersQuestionsWithCitations() throws {
        let document = DocumentMetadata(fileName: "lease.txt", fileURL: URL(filePath: "/tmp/lease.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: document.id, documentName: document.fileName, pageNumber: 4, text: "The lease can be terminated with sixty days written notice before renewal.")
        ]

        let response = LocalRAGEngine().answer(question: "How can the lease be terminated?", chunks: chunks)

        #expect(response.text.contains("sixty days"))
        #expect(response.citations.count == 1)
        #expect(response.citations[0].documentName == "lease.txt")
        #expect(response.citations[0].pageNumber == 4)
    }

    @Test("unknown answers are honest")
    func unknownAnswersAreHonest() throws {
        let document = DocumentMetadata(fileName: "invoice.txt", fileURL: URL(filePath: "/tmp/invoice.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: document.id, documentName: document.fileName, pageNumber: 1, text: "Invoice total is 400 dollars and payment is due May 20.")
        ]

        let response = LocalRAGEngine().answer(question: "What are the termination terms?", chunks: chunks)

        #expect(response.citations.isEmpty)
        #expect(response.text.contains("do not contain enough information"))
    }

    @Test("deleting document removes index data")
    @MainActor
    func deletingDocumentRemovesIndexData() async throws {
        let root = try TemporaryFiles.directory()
        let store = LibraryStore(storageDirectory: root)
        let fileURL = try TemporaryFiles.write(
            directory: root,
            name: "policy.txt",
            contents: "Remote work is permitted on Fridays with manager approval."
        )

        try await store.importDocument(fileURL)
        #expect(store.documents.count == 1)
        #expect(store.chunks.isEmpty == false)

        let id = try #require(store.documents.first?.id)
        store.deleteDocument(id: id)

        #expect(store.documents.isEmpty)
        #expect(store.chunks.isEmpty)
    }
}

private enum TemporaryFiles {
    static func directory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "VerityTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func write(name: String, contents: String) throws -> URL {
        try write(directory: try directory(), name: name, contents: contents)
    }

    static func write(directory: URL, name: String, contents: String) throws -> URL {
        let url = directory.appending(path: name)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
