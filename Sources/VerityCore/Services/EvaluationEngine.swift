import Foundation

public struct EvaluationEngine: Sendable {
    private let ragEngine: LocalRAGEngine

    public init(ragEngine: LocalRAGEngine = LocalRAGEngine()) {
        self.ragEngine = ragEngine
    }

    public func evaluate(questions: [String], chunks: [DocumentChunk]) -> EvaluationReport {
        let items = questions.map { question in
            let response = ragEngine.answer(question: question, chunks: chunks)
            let status: EvaluationStatus = response.citations.isEmpty ? .notFound : .answered
            return EvaluationItem(question: question, status: status, answer: response.text, citations: response.citations)
        }
        return EvaluationReport(items: items)
    }
}
