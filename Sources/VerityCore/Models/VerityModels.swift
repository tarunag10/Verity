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

public struct ImportProgress: Hashable, Sendable {
    public var completed: Int
    public var total: Int
    public var currentFileName: String?

    public init(completed: Int, total: Int, currentFileName: String? = nil) {
        self.completed = completed
        self.total = total
        self.currentFileName = currentFileName
    }

    public var fractionCompleted: Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(completed) / Double(total)))
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

public struct SourceReference: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var documentID: UUID
    public var title: String
    public var fileURL: URL
    public var fileType: String
    public var pageNumber: Int?
    public var snippet: String

    public init(
        id: UUID = UUID(),
        documentID: UUID,
        title: String,
        fileURL: URL,
        fileType: String,
        pageNumber: Int?,
        snippet: String
    ) {
        self.id = id
        self.documentID = documentID
        self.title = title
        self.fileURL = fileURL
        self.fileType = fileType
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
    public var telemetryEnabled: Bool

    public init(
        localOnlyMode: Bool = true,
        telemetryEnabled: Bool = false
    ) {
        self.localOnlyMode = localOnlyMode
        self.telemetryEnabled = telemetryEnabled
    }
}

public enum TemplateID: String, Codable, Hashable, Sendable, CaseIterable, Identifiable {
    case invoiceExtraction
    case contractReview
    case manualTroubleshooting
    case researchPaperSummary
    case policyReview
    case keyDates
    case compareDocuments

    public var id: String { rawValue }
}

public struct TemplateField: Identifiable, Codable, Hashable, Sendable {
    public var id: String { key }
    public var key: String
    public var label: String
    public var prompt: String

    public init(key: String, label: String, prompt: String) {
        self.key = key
        self.label = label
        self.prompt = prompt
    }
}

public struct TemplateDefinition: Identifiable, Codable, Hashable, Sendable {
    public var id: TemplateID
    public var name: String
    public var summary: String
    public var fields: [TemplateField]

    public init(id: TemplateID, name: String, summary: String, fields: [TemplateField]) {
        self.id = id
        self.name = name
        self.summary = summary
        self.fields = fields
    }
}

public struct ExtractedField: Identifiable, Codable, Hashable, Sendable {
    public var id: String { key }
    public var key: String
    public var label: String
    public var value: String
    public var citation: Citation?

    public init(key: String, label: String, value: String, citation: Citation?) {
        self.key = key
        self.label = label
        self.value = value
        self.citation = citation
    }
}

public struct TemplateRunResult: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var templateID: TemplateID
    public var templateName: String
    public var documentNames: [String]
    public var fields: [ExtractedField]
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        templateID: TemplateID,
        templateName: String,
        documentNames: [String],
        fields: [ExtractedField],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.templateID = templateID
        self.templateName = templateName
        self.documentNames = documentNames
        self.fields = fields
        self.createdAt = createdAt
    }
}

public enum EvaluationStatus: String, Codable, Hashable, Sendable {
    case answered
    case notFound
}

public struct EvaluationItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var question: String
    public var status: EvaluationStatus
    public var answer: String
    public var citations: [Citation]

    public init(id: UUID = UUID(), question: String, status: EvaluationStatus, answer: String, citations: [Citation]) {
        self.id = id
        self.question = question
        self.status = status
        self.answer = answer
        self.citations = citations
    }
}

public struct EvaluationReport: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var items: [EvaluationItem]
    public var createdAt: Date

    public init(id: UUID = UUID(), items: [EvaluationItem], createdAt: Date = Date()) {
        self.id = id
        self.items = items
        self.createdAt = createdAt
    }

    public var totalCount: Int {
        items.count
    }

    public var answeredCount: Int {
        items.filter { $0.status == .answered }.count
    }

    public var notFoundCount: Int {
        items.filter { $0.status == .notFound }.count
    }

    public var answerRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(answeredCount) / Double(totalCount)
    }
}

public enum ModelReadiness: String, Codable, Hashable, Sendable {
    case ready
    case fallback
    case needsModel
    case unavailable

    public var title: String {
        switch self {
        case .ready: "MLX ready"
        case .fallback: "Deterministic fallback"
        case .needsModel: "Model setup needed"
        case .unavailable: "Unavailable"
        }
    }

    public var systemImage: String {
        switch self {
        case .ready: "checkmark.seal.fill"
        case .fallback: "arrow.triangle.2.circlepath.circle.fill"
        case .needsModel: "square.and.arrow.down.fill"
        case .unavailable: "exclamationmark.triangle.fill"
        }
    }

    public var guidance: String {
        switch self {
        case .ready:
            "Verity is configured for local MLX retrieval and cited generation."
        case .fallback:
            "Verity can still import, search, extract, and answer using deterministic local retrieval."
        case .needsModel:
            "Choose local model identifiers or allow the MLX runtime to fetch them on first use."
        case .unavailable:
            "Local AI is not available with the current runtime configuration."
        }
    }
}

public struct ModelSettings: Codable, Hashable, Sendable {
    public var retrievalEngine: String
    public var answerEngine: String
    public var modelRuntime: String
    public var hardwareSummary: String
    public var languageModelIdentifier: String
    public var embeddingModelIdentifier: String

    public init(
        retrievalEngine: String = "Native MLX embeddings with lexical fallback",
        answerEngine: String = "Native MLX chat model with cited prompts",
        modelRuntime: String = "MLX Swift in-process runtime",
        hardwareSummary: String = "Apple Silicon recommended",
        languageModelIdentifier: String = "mlx-community/Qwen3-4B-4bit",
        embeddingModelIdentifier: String = "sentence-transformers/all-MiniLM-L6-v2"
    ) {
        self.retrievalEngine = retrievalEngine
        self.answerEngine = answerEngine
        self.modelRuntime = modelRuntime
        self.hardwareSummary = hardwareSummary
        self.languageModelIdentifier = languageModelIdentifier
        self.embeddingModelIdentifier = embeddingModelIdentifier
    }

    public var readiness: ModelReadiness {
        let combined = [
            retrievalEngine,
            answerEngine,
            modelRuntime,
            languageModelIdentifier,
            embeddingModelIdentifier
        ].joined(separator: " ").lowercased()

        if combined.contains("unavailable") || combined.contains("unsupported") {
            return .unavailable
        }

        if languageModelIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            embeddingModelIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .needsModel
        }

        if combined.contains("fallback") || combined.contains("deterministic") || combined.contains("lexical") {
            return .fallback
        }

        if combined.contains("mlx") {
            return .ready
        }

        return .needsModel
    }
}
