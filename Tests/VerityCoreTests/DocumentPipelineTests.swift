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

    @Test("resolves citation source reference")
    @MainActor
    func resolvesCitationSourceReference() async throws {
        let root = try TemporaryFiles.directory()
        let store = LibraryStore(storageDirectory: root)
        let fileURL = try TemporaryFiles.write(
            directory: root,
            name: "lease.txt",
            contents: "The lease can be terminated with sixty days written notice before renewal."
        )

        try await store.importDocument(fileURL)
        store.ask("How can the lease be terminated?")

        let citation = try #require(store.activeChat?.messages.last?.citations.first)
        let source = try #require(store.sourceReference(for: citation))

        #expect(source.title == "lease.txt")
        #expect(source.fileURL == fileURL)
        #expect(source.fileType == "txt")
        #expect(source.pageNumber == 1)
        #expect(source.snippet.contains("sixty days"))
    }

    @Test("deleted document citation cannot resolve")
    @MainActor
    func deletedDocumentCitationCannotResolve() async throws {
        let root = try TemporaryFiles.directory()
        let store = LibraryStore(storageDirectory: root)
        let fileURL = try TemporaryFiles.write(
            directory: root,
            name: "policy.txt",
            contents: "Invoices must be approved by finance before payment."
        )

        try await store.importDocument(fileURL)
        store.ask("Who approves invoices?")
        let citation = try #require(store.activeChat?.messages.last?.citations.first)
        let documentID = citation.documentID

        store.deleteDocument(id: documentID)

        #expect(store.sourceReference(for: citation) == nil)
    }

    @Test("built in templates include invoice and contract")
    func builtInTemplatesIncludeInvoiceAndContract() throws {
        let templates = TemplateEngine.builtInTemplates

        #expect(templates.contains { $0.id == .invoiceExtraction })
        #expect(templates.contains { $0.id == .contractReview })
        #expect(templates.first { $0.id == .invoiceExtraction }?.fields.map(\.key).contains("invoiceNumber") == true)
    }

    @Test("invoice template extracts fields with citations")
    func invoiceTemplateExtractsFieldsWithCitations() throws {
        let document = DocumentMetadata(fileName: "invoice.txt", fileURL: URL(filePath: "/tmp/invoice.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(
                documentID: document.id,
                documentName: document.fileName,
                pageNumber: 1,
                text: """
                Vendor: Acme Supplies
                Invoice Number: INV-2048
                Invoice Date: May 1, 2026
                Due Date: May 31, 2026
                Total: $1,240.50
                Payment Terms: Net 30
                """
            )
        ]

        let result = TemplateEngine().run(templateID: .invoiceExtraction, documents: [document], chunks: chunks)

        #expect(result.fields.first { $0.key == "vendor" }?.value == "Acme Supplies")
        #expect(result.fields.first { $0.key == "invoiceNumber" }?.value == "INV-2048")
        #expect(result.fields.first { $0.key == "total" }?.value == "$1,240.50")
        #expect(result.fields.first { $0.key == "vendor" }?.citation?.documentName == "invoice.txt")
    }

    @Test("template result exports CSV")
    func templateResultExportsCSV() throws {
        let result = TemplateRunResult(
            templateID: .invoiceExtraction,
            templateName: "Invoice Extraction",
            documentNames: ["invoice.txt"],
            fields: [
                ExtractedField(key: "vendor", label: "Vendor", value: "Acme, Inc.", citation: nil),
                ExtractedField(key: "total", label: "Total", value: "$100.00", citation: nil)
            ]
        )

        let csv = TemplateEngine().exportCSV(results: [result])

        #expect(csv.contains("\"Invoice Extraction\",\"invoice.txt\",\"Vendor\",\"Acme, Inc.\""))
        #expect(csv.contains("\"Invoice Extraction\",\"invoice.txt\",\"Total\",\"$100.00\""))
    }

    @Test("folder import indexes supported files")
    @MainActor
    func folderImportIndexesSupportedFiles() async throws {
        let root = try TemporaryFiles.directory()
        let folder = root.appending(path: "client", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        _ = try TemporaryFiles.write(directory: folder, name: "contract.md", contents: "Renewal date: June 30, 2026.")
        _ = try TemporaryFiles.write(directory: folder, name: "notes.txt", contents: "Payment terms are Net 15.")
        _ = try TemporaryFiles.write(directory: folder, name: "image.png", contents: "not supported")

        let store = LibraryStore(storageDirectory: root.appending(path: "state", directoryHint: .isDirectory))
        try await store.importFolder(folder)

        #expect(store.documents.map(\.fileName).sorted() == ["contract.md", "notes.txt"])
        #expect(store.chunks.count == 2)
    }

    @Test("evaluation flags answered and unanswered questions")
    func evaluationFlagsAnsweredAndUnansweredQuestions() throws {
        let document = DocumentMetadata(fileName: "policy.txt", fileURL: URL(filePath: "/tmp/policy.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: document.id, documentName: document.fileName, pageNumber: 1, text: "Refund requests must be submitted within 14 days.")
        ]

        let report = EvaluationEngine().evaluate(
            questions: ["What is the refund window?", "Who signs vendor contracts?"],
            chunks: chunks
        )

        #expect(report.items.first?.status == .answered)
        #expect(report.items.last?.status == .notFound)
    }

    @Test("vector index ranks chunks by embedding similarity")
    func vectorIndexRanksChunksByEmbeddingSimilarity() async throws {
        let alpha = DocumentMetadata(fileName: "alpha.txt", fileURL: URL(filePath: "/tmp/alpha.txt"), fileType: "txt")
        let beta = DocumentMetadata(fileName: "beta.txt", fileURL: URL(filePath: "/tmp/beta.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: alpha.id, documentName: alpha.fileName, pageNumber: 1, text: "alpha topic"),
            DocumentChunk(documentID: beta.id, documentName: beta.fileName, pageNumber: 1, text: "beta topic")
        ]
        let embeddings = StaticEmbeddingProvider(vectorsByText: [
            "alpha topic": [1, 0],
            "beta topic": [0, 1],
            "find beta": [0, 1]
        ])
        let index = InMemoryVectorIndex(embeddingProvider: embeddings)

        try await index.replaceAll(chunks)
        let matches = try await index.search("find beta", limit: 2)

        #expect(matches.map(\.chunk.documentName) == ["beta.txt", "alpha.txt"])
        #expect(matches[0].score > matches[1].score)
    }

    @Test("local AI runtime composes cited prompts for generators")
    func localAIRuntimeComposesCitedPromptsForGenerators() async throws {
        let document = DocumentMetadata(fileName: "lease.txt", fileURL: URL(filePath: "/tmp/lease.txt"), fileType: "txt")
        let chunks = [
            DocumentChunk(documentID: document.id, documentName: document.fileName, pageNumber: 4, text: "The lease requires sixty days written notice.")
        ]
        let generator = RecordingAnswerGenerator(reply: "The lease requires sixty days written notice.")
        let runtime = LocalAIRuntime(answerGenerator: generator, embeddingProvider: nil)

        let response = try await runtime.answer(question: "How much notice is required?", chunks: chunks)

        #expect(response.text == "The lease requires sixty days written notice.")
        #expect(response.citations.count == 1)
        #expect(response.citations[0].documentName == "lease.txt")
        let prompt = await generator.lastPrompt ?? ""
        #expect(prompt.contains("Use only the cited source excerpts"))
        #expect(prompt.contains("[1] lease.txt page 4"))
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

private struct StaticEmbeddingProvider: LocalEmbeddingProvider {
    var identifier: String { "static-test-embeddings" }
    var vectorsByText: [String: [Float]]

    func embed(_ texts: [String]) async throws -> [[Float]] {
        texts.map { vectorsByText[$0] ?? [0, 0] }
    }
}

private actor RecordingAnswerGenerator: LocalAnswerGenerator {
    nonisolated let identifier = "recording-test-generator"
    private(set) var lastPrompt: String?
    private let reply: String

    init(reply: String) {
        self.reply = reply
    }

    func generate(prompt: String) async throws -> String {
        lastPrompt = prompt
        return reply
    }
}
