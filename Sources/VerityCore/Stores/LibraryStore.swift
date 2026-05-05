import Foundation

@MainActor
public final class LibraryStore: ObservableObject {
    @Published public private(set) var documents: [DocumentMetadata]
    @Published public private(set) var chunks: [DocumentChunk]
    @Published public var chats: [ChatThread]
    @Published public var activeChatID: UUID?
    @Published public var selectedDocumentID: UUID?
    @Published public var privacySettings: PrivacySettings

    public let storageDirectory: URL
    private let parser: DocumentParser
    private let chunker: DocumentChunker
    private let engine: LocalRAGEngine

    private var stateURL: URL {
        storageDirectory.appending(path: "verity-library.json")
    }

    public init(
        storageDirectory: URL,
        parser: DocumentParser = DocumentParser(),
        chunker: DocumentChunker = DocumentChunker(),
        engine: LocalRAGEngine = LocalRAGEngine()
    ) {
        self.storageDirectory = storageDirectory
        self.parser = parser
        self.chunker = chunker
        self.engine = engine
        let initialChat = ChatThread()
        self.documents = []
        self.chunks = []
        self.chats = [initialChat]
        self.activeChatID = initialChat.id
        self.privacySettings = PrivacySettings()
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

    public func documentURL(for id: UUID) -> URL? {
        documents.first { $0.id == id }?.fileURL
    }

    private func scopedChunks(_ scope: Set<UUID>) -> [DocumentChunk] {
        scope.isEmpty ? chunks : chunks.filter { scope.contains($0.documentID) }
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
            privacySettings: privacySettings
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
    }
}

private struct LibrarySnapshot: Codable {
    var documents: [DocumentMetadata]
    var chunks: [DocumentChunk]
    var chats: [ChatThread]
    var activeChatID: UUID?
    var selectedDocumentID: UUID?
    var privacySettings: PrivacySettings
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
