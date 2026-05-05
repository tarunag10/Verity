import Foundation

public enum DocumentStatus: String, Codable, Sendable, CaseIterable {
    case imported
    case indexing
    case ready
    case failed
    case ocrNeeded
}

public enum TextQuality: String, Codable, Sendable {
    case selectableText
    case lowText
    case imageOnly
}

public struct DocumentMetadata: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var fileName: String
    public var fileURL: URL
    public var fileType: String
    public var createdAt: Date?
    public var modifiedAt: Date?
    public var importedAt: Date
    public var pageCount: Int
    public var status: DocumentStatus
    public var failureReason: String?

    public init(
        id: UUID = UUID(),
        fileName: String,
        fileURL: URL,
        fileType: String,
        createdAt: Date? = nil,
        modifiedAt: Date? = nil,
        importedAt: Date = Date(),
        pageCount: Int = 1,
        status: DocumentStatus = .imported,
        failureReason: String? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.fileType = fileType
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.importedAt = importedAt
        self.pageCount = pageCount
        self.status = status
        self.failureReason = failureReason
    }
}

public struct ParsedPage: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var pageNumber: Int
    public var text: String

    public init(id: UUID = UUID(), pageNumber: Int, text: String) {
        self.id = id
        self.pageNumber = pageNumber
        self.text = text
    }
}

public struct ParsedDocument: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID { metadata.id }
    public var metadata: DocumentMetadata
    public var pages: [ParsedPage]
    public var textQuality: TextQuality
    public var status: DocumentStatus

    public init(metadata: DocumentMetadata, pages: [ParsedPage], textQuality: TextQuality, status: DocumentStatus) {
        self.metadata = metadata
        self.pages = pages
        self.textQuality = textQuality
        self.status = status
    }
}

public struct DocumentChunk: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var documentID: UUID
    public var documentName: String
    public var pageNumber: Int?
    public var text: String

    public init(id: UUID = UUID(), documentID: UUID, documentName: String, pageNumber: Int?, text: String) {
        self.id = id
        self.documentID = documentID
        self.documentName = documentName
        self.pageNumber = pageNumber
        self.text = text
    }
}

public struct Citation: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var documentID: UUID
    public var documentName: String
    public var pageNumber: Int?
    public var snippet: String

    public init(id: UUID = UUID(), documentID: UUID, documentName: String, pageNumber: Int?, snippet: String) {
        self.id = id
        self.documentID = documentID
        self.documentName = documentName
        self.pageNumber = pageNumber
        self.snippet = snippet
    }
}

public struct SearchResult: Identifiable, Hashable, Sendable {
    public var id: UUID { chunk.id }
    public var chunk: DocumentChunk
    public var score: Double
    public var snippet: String

    public init(chunk: DocumentChunk, score: Double, snippet: String) {
        self.chunk = chunk
        self.score = score
        self.snippet = snippet
    }
}

public struct AssistantResponse: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var text: String
    public var citations: [Citation]

    public init(id: UUID = UUID(), text: String, citations: [Citation]) {
        self.id = id
        self.text = text
        self.citations = citations
    }
}

public enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
}

public struct ChatMessage: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var role: ChatRole
    public var text: String
    public var citations: [Citation]
    public var createdAt: Date

    public init(id: UUID = UUID(), role: ChatRole, text: String, citations: [Citation] = [], createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.citations = citations
        self.createdAt = createdAt
    }
}

public struct ChatThread: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var messages: [ChatMessage]
    public var documentScope: Set<UUID>
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [ChatMessage] = [],
        documentScope: Set<UUID> = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.documentScope = documentScope
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct PrivacySettings: Codable, Hashable, Sendable {
    public var localOnlyMode: Bool
    public var syncEnabled: Bool
    public var telemetryEnabled: Bool
    public var ocrEnabled: Bool
    public var modelName: String

    public init(
        localOnlyMode: Bool = true,
        syncEnabled: Bool = false,
        telemetryEnabled: Bool = false,
        ocrEnabled: Bool = false,
        modelName: String = "Local lexical MVP engine"
    ) {
        self.localOnlyMode = localOnlyMode
        self.syncEnabled = syncEnabled
        self.telemetryEnabled = telemetryEnabled
        self.ocrEnabled = ocrEnabled
        self.modelName = modelName
    }
}
