import Foundation

public protocol LocalEmbeddingProvider: Sendable {
    var identifier: String { get }
    func embed(_ texts: [String]) async throws -> [[Float]]
}

public protocol LocalAnswerGenerator: Sendable {
    var identifier: String { get }
    func generate(prompt: String) async throws -> String
}

public struct VectorSearchMatch: Identifiable, Hashable, Sendable {
    public var id: UUID { chunk.id }
    public var chunk: DocumentChunk
    public var score: Double

    public init(chunk: DocumentChunk, score: Double) {
        self.chunk = chunk
        self.score = score
    }
}

public actor InMemoryVectorIndex {
    private struct Entry: Sendable {
        var chunk: DocumentChunk
        var vector: [Float]
    }

    public let embeddingProvider: any LocalEmbeddingProvider
    private var entries: [Entry]

    public init(embeddingProvider: any LocalEmbeddingProvider) {
        self.embeddingProvider = embeddingProvider
        self.entries = []
    }

    public func replaceAll(_ chunks: [DocumentChunk]) async throws {
        let vectors = try await embeddingProvider.embed(chunks.map(\.text))
        entries = zip(chunks, vectors).map { Entry(chunk: $0.0, vector: $0.1) }
    }

    public func search(_ query: String, limit: Int = 5) async throws -> [VectorSearchMatch] {
        guard limit > 0, entries.isEmpty == false else { return [] }
        let queryVector = try await embeddingProvider.embed([query]).first ?? []
        return entries
            .map { VectorSearchMatch(chunk: $0.chunk, score: cosineSimilarity(queryVector, $0.vector)) }
            .sorted { left, right in
                if left.score == right.score {
                    return left.chunk.documentName < right.chunk.documentName
                }
                return left.score > right.score
            }
            .prefix(limit)
            .map { $0 }
    }
}

public struct LocalAIRuntime: Sendable {
    public var answerGenerator: any LocalAnswerGenerator
    public var embeddingProvider: (any LocalEmbeddingProvider)?

    public init(answerGenerator: any LocalAnswerGenerator, embeddingProvider: (any LocalEmbeddingProvider)?) {
        self.answerGenerator = answerGenerator
        self.embeddingProvider = embeddingProvider
    }

    public func answer(question: String, chunks: [DocumentChunk]) async throws -> AssistantResponse {
        guard chunks.isEmpty == false else {
            return AssistantResponse(
                text: "The local sources do not contain enough information to answer that.",
                citations: []
            )
        }

        let selectedChunks = Array(chunks.prefix(5))
        let prompt = Self.citedPrompt(question: question, chunks: selectedChunks)
        let text = try await answerGenerator.generate(prompt: prompt).trimmingCharacters(in: .whitespacesAndNewlines)
        let citations = selectedChunks.map {
            Citation(
                documentID: $0.documentID,
                documentName: $0.documentName,
                pageNumber: $0.pageNumber,
                snippet: $0.text
            )
        }
        return AssistantResponse(text: text, citations: citations)
    }

    public static func citedPrompt(question: String, chunks: [DocumentChunk]) -> String {
        let sourceText = chunks.enumerated().map { index, chunk in
            let page = chunk.pageNumber.map { " page \($0)" } ?? ""
            return "[\(index + 1)] \(chunk.documentName)\(page)\n\(chunk.text)"
        }.joined(separator: "\n\n")

        return """
        You are Verity, a private local document assistant.
        Use only the cited source excerpts below. If the answer is not in the sources, say that the local sources do not contain enough information.
        Keep the answer concise and preserve important numbers, dates, names, and obligations.

        Question:
        \(question)

        Source excerpts:
        \(sourceText)
        """
    }
}

private func cosineSimilarity(_ lhs: [Float], _ rhs: [Float]) -> Double {
    let count = min(lhs.count, rhs.count)
    guard count > 0 else { return 0 }

    var dot: Float = 0
    var lhsMagnitude: Float = 0
    var rhsMagnitude: Float = 0
    for index in 0..<count {
        dot += lhs[index] * rhs[index]
        lhsMagnitude += lhs[index] * lhs[index]
        rhsMagnitude += rhs[index] * rhs[index]
    }

    guard lhsMagnitude > 0, rhsMagnitude > 0 else { return 0 }
    return Double(dot / (sqrt(lhsMagnitude) * sqrt(rhsMagnitude)))
}
