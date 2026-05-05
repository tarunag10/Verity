import Foundation

@MainActor
public final class LibraryStore: ObservableObject {
    @Published public private(set) var documents: [DocumentMetadata]
    @Published public private(set) var chunks: [DocumentChunk]
    @Published public var chats: [ChatThread]
    @Published public var activeChatID: UUID?
    @Published public var selectedDocumentID: UUID?
    @Published public var privacySettings: PrivacySettings
    @Published public var modelSettings: ModelSettings
    @Published public private(set) var templateResults: [TemplateRunResult]
    @Published public private(set) var evaluationReports: [EvaluationReport]

    public let storageDirectory: URL
    private let parser: DocumentParser
    private let chunker: DocumentChunker
    private let engine: LocalRAGEngine
    private let templateEngine: TemplateEngine
    private let evaluationEngine: EvaluationEngine

    private var stateURL: URL {
        storageDirectory.appending(path: "verity-library.json")
    }

    public init(
        storageDirectory: URL,
        parser: DocumentParser = DocumentParser(),
        chunker: DocumentChunker = DocumentChunker(),
        engine: LocalRAGEngine = LocalRAGEngine(),
        templateEngine: TemplateEngine = TemplateEngine(),
        evaluationEngine: EvaluationEngine = EvaluationEngine()
    ) {
        self.storageDirectory = storageDirectory
        self.parser = parser
        self.chunker = chunker
        self.engine = engine
        self.templateEngine = templateEngine
        self.evaluationEngine = evaluationEngine
        let initialChat = ChatThread()
        self.documents = []
        self.chunks = []
        self.chats = [initialChat]
        self.activeChatID = initialChat.id
        self.privacySettings = PrivacySettings()
        self.modelSettings = ModelSettings()
        self.templateResults = []
        self.evaluationReports = []
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        load()
    }

    public var activeChat: ChatThread? {
        get { chats.first { $0.id == activeChatID } }
        set {
            guard let newValue, let index = chats.firstIndex(where: { $0.id == newValue.id }) else { return }
            chats[index] = newValue
        }
    }

    public func importDocument(_ fileURL: URL) async throws {
        var parsed = try parser.parse(fileURL: fileURL)
        parsed.metadata.status = .indexing
        documents.append(parsed.metadata)
        persist()

        let newChunks = chunker.chunk(parsed)
        parsed.metadata.status = parsed.status
        if let index = documents.firstIndex(where: { $0.id == parsed.id }) {
            documents[index] = parsed.metadata
        }
        chunks.append(contentsOf: newChunks)
        selectedDocumentID = parsed.id
        persist()
    }

    public func importFolder(_ folderURL: URL) async throws {
        for fileURL in try supportedFileURLs(in: folderURL) {
            try await importDocument(fileURL)
        }
    }

    public func deleteDocument(id: UUID) {
        documents.removeAll { $0.id == id }
        chunks.removeAll { $0.documentID == id }
        chats = chats.map { chat in
            var copy = chat
            copy.documentScope.remove(id)
            return copy
        }
        if selectedDocumentID == id {
            selectedDocumentID = documents.first?.id
        }
        templateResults.removeAll { result in
            !Set(result.documentNames).isDisjoint(with: [documents.first { $0.id == id }?.fileName].compactMap { $0 })
        }
        persist()
    }

    public func search(_ query: String, scope: Set<UUID> = []) -> [SearchResult] {
        engine.search(query: query, chunks: scopedChunks(scope))
    }

    public func ask(_ question: String, scope: Set<UUID> = []) {
        let userMessage = ChatMessage(role: .user, text: question)
        let response = engine.answer(question: question, chunks: scopedChunks(scope))
        let assistantMessage = ChatMessage(role: .assistant, text: response.text, citations: response.citations)
        append(messages: [userMessage, assistantMessage], question: question, scope: scope)
    }

    public func summarize(scope: Set<UUID> = []) {
        let response = engine.summarize(chunks: scopedChunks(scope), documentID: scope.count == 1 ? scope.first : nil)
        let assistantMessage = ChatMessage(role: .assistant, text: response.text, citations: response.citations)
        append(messages: [assistantMessage], question: "Summary", scope: scope)
    }

    public func newChat() {
        let chat = ChatThread()
        chats.insert(chat, at: 0)
        activeChatID = chat.id
        persist()
    }

    public func deleteActiveChat() {
        guard let activeChatID else { return }
        chats.removeAll { $0.id == activeChatID }
        if chats.isEmpty {
            chats.append(ChatThread())
        }
        self.activeChatID = chats.first?.id
        persist()
    }

    public func updatePrivacySettings(_ settings: PrivacySettings) {
        privacySettings = settings
        persist()
    }

    public func updateModelSettings(_ settings: ModelSettings) {
        modelSettings = settings
        persist()
    }

    @discardableResult
    public func runTemplate(_ templateID: TemplateID, documentIDs: Set<UUID>) -> TemplateRunResult {
        let selectedDocuments = documentIDs.isEmpty ? documents : documents.filter { documentIDs.contains($0.id) }
        let selectedIDs = Set(selectedDocuments.map(\.id))
        let selectedChunks = chunks.filter { selectedIDs.isEmpty || selectedIDs.contains($0.documentID) }
        let result = templateEngine.run(templateID: templateID, documents: selectedDocuments, chunks: selectedChunks)
        templateResults.insert(result, at: 0)
        persist()
        return result
    }

    public func exportTemplateResultsCSV() -> String {
        templateEngine.exportCSV(results: templateResults)
    }

    @discardableResult
    public func runEvaluation(questions: [String]? = nil) -> EvaluationReport {
        let questions = questions ?? LibraryStore.defaultEvaluationQuestions
        let report = evaluationEngine.evaluate(questions: questions, chunks: chunks)
        evaluationReports.insert(report, at: 0)
        persist()
        return report
    }

    public func deleteAllLocalData() {
        documents = []
        chunks = []
        chats = [ChatThread()]
        activeChatID = chats.first?.id
        selectedDocumentID = nil
        templateResults = []
        evaluationReports = []
        persist()
    }

    public func documentURL(for id: UUID) -> URL? {
        documents.first { $0.id == id }?.fileURL
    }

    public func sourceReference(for citation: Citation) -> SourceReference? {
        guard let document = documents.first(where: { $0.id == citation.documentID }) else {
            return nil
        }

        return SourceReference(
            documentID: document.id,
            title: document.fileName,
            fileURL: document.fileURL,
            fileType: document.fileType,
            pageNumber: citation.pageNumber,
            snippet: citation.snippet
        )
    }

    private func scopedChunks(_ scope: Set<UUID>) -> [DocumentChunk] {
        scope.isEmpty ? chunks : chunks.filter { scope.contains($0.documentID) }
    }

    private func supportedFileURLs(in folderURL: URL) throws -> [URL] {
        let supported = Set(["pdf", "txt", "md", "markdown", "rtf"])
        let contents = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var files: [URL] = []
        for url in contents {
            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])
            if values.isDirectory == true {
                files.append(contentsOf: try supportedFileURLs(in: url))
            } else if values.isRegularFile == true, supported.contains(url.pathExtension.lowercased()) {
                files.append(url)
            }
        }
        return files.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func append(messages: [ChatMessage], question: String, scope: Set<UUID>) {
        if activeChatID == nil || !chats.contains(where: { $0.id == activeChatID }) {
            newChat()
        }
        guard let id = activeChatID, let index = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[index].messages.append(contentsOf: messages)
        chats[index].documentScope = scope
        chats[index].updatedAt = Date()
        if chats[index].title == "New Chat", question != "Summary" {
            chats[index].title = String(question.prefix(42))
        }
        persist()
    }

    private func persist() {
        let snapshot = LibrarySnapshot(
            documents: documents,
            chunks: chunks,
            chats: chats,
            activeChatID: activeChatID,
            selectedDocumentID: selectedDocumentID,
            privacySettings: privacySettings,
            modelSettings: modelSettings,
            templateResults: templateResults,
            evaluationReports: evaluationReports
        )
        do {
            let data = try JSONEncoder.verity.encode(snapshot)
            try data.write(to: stateURL, options: [.atomic])
        } catch {
            assertionFailure("Could not persist Verity library: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: stateURL),
              let snapshot = try? JSONDecoder.verity.decode(LibrarySnapshot.self, from: data) else {
            return
        }
        documents = snapshot.documents
        chunks = snapshot.chunks
        chats = snapshot.chats.isEmpty ? [ChatThread()] : snapshot.chats
        activeChatID = snapshot.activeChatID ?? chats.first?.id
        selectedDocumentID = snapshot.selectedDocumentID
        privacySettings = snapshot.privacySettings
        modelSettings = snapshot.modelSettings ?? ModelSettings()
        templateResults = snapshot.templateResults ?? []
        evaluationReports = snapshot.evaluationReports ?? []
    }

    public static let defaultEvaluationQuestions = [
        "What is the main obligation?",
        "What are the payment terms?",
        "What dates or deadlines are mentioned?",
        "What risks or warnings are described?",
        "What information is not available in the documents?"
    ]
}

private struct LibrarySnapshot: Codable {
    var documents: [DocumentMetadata]
    var chunks: [DocumentChunk]
    var chats: [ChatThread]
    var activeChatID: UUID?
    var selectedDocumentID: UUID?
    var privacySettings: PrivacySettings
    var modelSettings: ModelSettings?
    var templateResults: [TemplateRunResult]?
    var evaluationReports: [EvaluationReport]?
}

private extension JSONEncoder {
    static var verity: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var verity: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
