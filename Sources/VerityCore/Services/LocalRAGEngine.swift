import Foundation

public struct LocalRAGEngine: Sendable {
    private let stopwords: Set<String> = [
        "a", "an", "and", "are", "as", "at", "be", "by", "can", "for", "from", "how", "in", "is", "it", "of",
        "on", "or", "the", "to", "what", "when", "where", "which", "who", "with"
    ]

    public init() {}

    public func search(query: String, chunks: [DocumentChunk], limit: Int = 6) -> [SearchResult] {
        let queryTerms = tokens(query)
        guard !queryTerms.isEmpty else { return [] }

        return chunks.compactMap { chunk in
            let chunkTerms = tokens(chunk.text)
            let overlap = queryTerms.intersection(chunkTerms)
            guard !overlap.isEmpty else { return nil }

            let density = Double(overlap.count) / Double(max(queryTerms.count, 1))
            let phraseBoost = chunk.text.localizedCaseInsensitiveContains(query) ? 0.6 : 0
            let titleBoost = chunk.documentName.localizedCaseInsensitiveContains(query) ? 0.2 : 0
            let score = density + phraseBoost + titleBoost
            return SearchResult(chunk: chunk, score: score, snippet: snippet(from: chunk.text, queryTerms: queryTerms))
        }
        .sorted { lhs, rhs in
            if lhs.score == rhs.score {
                lhs.chunk.text.count < rhs.chunk.text.count
            } else {
                lhs.score > rhs.score
            }
        }
        .prefix(limit)
        .map { $0 }
    }

    public func answer(question: String, chunks: [DocumentChunk], limit: Int = 4) -> AssistantResponse {
        let results = search(query: question, chunks: chunks, limit: limit)
        guard let best = results.first, best.score >= 0.34 else {
            return AssistantResponse(
                text: "The selected documents do not contain enough information to answer that with confidence.",
                citations: []
            )
        }

        let selected = [best] + results.dropFirst().filter { $0.score >= 0.34 }
        let citations = selected.map {
            Citation(
                documentID: $0.chunk.documentID,
                documentName: $0.chunk.documentName,
                pageNumber: $0.chunk.pageNumber,
                snippet: $0.snippet
            )
        }
        let answerText = selected
            .map { cleanSentence($0.chunk.text) }
            .joined(separator: "\n\n")

        return AssistantResponse(text: answerText, citations: citations)
    }

    public func summarize(chunks: [DocumentChunk], documentID: UUID? = nil, sentenceLimit: Int = 4) -> AssistantResponse {
        let scoped = documentID.map { id in chunks.filter { $0.documentID == id } } ?? chunks
        let selected = scoped.prefix(sentenceLimit)
        let citations = selected.map {
            Citation(documentID: $0.documentID, documentName: $0.documentName, pageNumber: $0.pageNumber, snippet: snippet(from: $0.text, queryTerms: []))
        }
        let text = selected.map { cleanSentence($0.text) }.joined(separator: "\n\n")
        return AssistantResponse(text: text.isEmpty ? "No readable text is available to summarize." : text, citations: citations)
    }

    private func tokens(_ text: String) -> Set<String> {
        let parts = text.lowercased().split { character in
            !character.isLetter && !character.isNumber
        }
        return Set(parts.map(String.init).filter { $0.count > 2 && !stopwords.contains($0) })
    }

    private func snippet(from text: String, queryTerms: Set<String>) -> String {
        let sentences = text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".?!"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let selected = sentences.first { sentence in
            let sentenceTokens = tokens(sentence)
            return !queryTerms.isDisjoint(with: sentenceTokens)
        } ?? sentences.first ?? text

        return String(selected.prefix(240))
    }

    private func cleanSentence(_ text: String) -> String {
        let normalized = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return String(normalized.prefix(900))
    }
}
