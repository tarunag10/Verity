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
            guard satisfiesRequiredConcepts(queryTerms: queryTerms, chunkTerms: chunkTerms) else {
                return nil
            }

            let overlap = queryTerms.intersection(chunkTerms)
            guard !overlap.isEmpty else { return nil }

            let density = Double(overlap.count) / Double(max(queryTerms.count, 1))
            let phraseBoost = phraseBoost(for: query, in: chunk.text)
            let titleOverlap = queryTerms.intersection(tokens(chunk.documentName))
            let titleBoost = Double(titleOverlap.count) * 0.08
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
        return Set(parts.compactMap { part in
            normalizedToken(String(part))
        })
    }

    private func normalizedToken(_ token: String) -> String? {
        guard token.count > 2, !stopwords.contains(token) else { return nil }

        switch token {
        case "agreements", "agreement", "contracts", "contract":
            return "agreement"
        case "fees", "fee", "payment", "payments", "payable", "paid", "pay", "pays":
            return "payment"
        case "term", "terms":
            return "term"
        case "termination", "terminations", "terminate", "terminated", "terminates", "terminating":
            return "terminate"
        case "renewal", "renewals", "renew", "renews", "renewed", "renewing":
            return "renew"
        case "effective":
            return "effective"
        case "expiration", "expires", "expired", "expiry":
            return "expire"
        case "invoice", "invoices":
            return "invoice"
        case "number", "numbers", "identifier", "identifiers":
            return "number"
        case "total", "totals", "amount", "amounts":
            return "amount"
        case "vendor", "vendors", "supplier", "suppliers":
            return "vendor"
        case "party", "parties":
            return "party"
        case "obligation", "obligations", "required", "requires", "requirement", "requirements":
            return "obligation"
        case "risk", "risks":
            return "risk"
        case "exception", "exceptions":
            return "exception"
        case "warning", "warnings":
            return "warning"
        case "warranty", "warranties":
            return "warranty"
        case "troubleshooting", "troubleshoot":
            return "troubleshoot"
        case "governing", "governed", "governs", "govern":
            return "govern"
        case "laws", "law":
            return "law"
        case "jurisdiction", "jurisdictions", "venue":
            return "jurisdiction"
        default:
            if token.count > 4, token.hasSuffix("ies") {
                return String(token.dropLast(3)) + "y"
            }
            if token.count > 4, token.hasSuffix("es") {
                return String(token.dropLast(2))
            }
            if token.count > 3, token.hasSuffix("s") {
                return String(token.dropLast())
            }
            return token
        }
    }

    private func satisfiesRequiredConcepts(queryTerms: Set<String>, chunkTerms: Set<String>) -> Bool {
        for requirement in conceptRequirements(for: queryTerms) {
            guard requirement.contains(where: chunkTerms.contains) else {
                return false
            }
        }

        return true
    }

    private func conceptRequirements(for queryTerms: Set<String>) -> [Set<String>] {
        let pairedRequirements: [(Set<String>, [Set<String>])] = [
            (["govern", "law"], [["govern", "jurisdiction"], ["law"]]),
            (["payment", "term"], [["payment"]]),
            (["terminate", "term"], [["terminate"]]),
            (["renew", "date"], [["renew"]]),
            (["effective", "date"], [["effective"]]),
            (["expire", "date"], [["expire"]]),
            (["due", "date"], [["due", "payment"]]),
            (["invoice", "number"], [["invoice"], ["number"]]),
            (["invoice", "date"], [["invoice"], ["date"]]),
            (["amount", "due"], [["amount", "payment"]]),
            (["vendor", "name"], [["vendor"]])
        ]

        var requirements: [Set<String>] = []
        for (trigger, requiredConcepts) in pairedRequirements where trigger.isSubset(of: queryTerms) {
            requirements.append(contentsOf: requiredConcepts)
        }

        for concept in ["terminate", "renew", "effective", "expire", "vendor", "party", "obligation", "risk", "exception", "warning", "warranty", "troubleshoot"] {
            if queryTerms.contains(concept) {
                requirements.append([concept])
            }
        }

        return requirements
    }

    private func phraseBoost(for query: String, in text: String) -> Double {
        let lowerText = text.lowercased()
        if lowerText.localizedCaseInsensitiveContains(query) {
            return 0.6
        }

        if lowerText.contains("governing law") ||
            lowerText.contains("governed by") ||
            lowerText.contains("laws of") ||
            lowerText.contains("payment terms") ||
            lowerText.contains("payable net") ||
            lowerText.contains("may terminate") ||
            lowerText.contains("written notice") ||
            lowerText.contains("renewal date") ||
            lowerText.contains("effective date") ||
            lowerText.contains("invoice number") ||
            lowerText.contains("amount due") {
            return 0.45
        }

        return 0
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
