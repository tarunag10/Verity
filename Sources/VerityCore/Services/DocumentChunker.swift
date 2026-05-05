import Foundation

public struct DocumentChunker: Sendable {
    private let targetWordCount: Int

    public init(targetWordCount: Int = 140) {
        self.targetWordCount = max(8, targetWordCount)
    }

    public func chunk(_ document: ParsedDocument) -> [DocumentChunk] {
        document.pages.flatMap { page in
            chunks(for: page.text).map { text in
                DocumentChunk(
                    documentID: document.metadata.id,
                    documentName: document.metadata.fileName,
                    pageNumber: page.pageNumber,
                    text: text
                )
            }
        }
    }

    private func chunks(for text: String) -> [String] {
        let paragraphs = text
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var chunks: [String] = []
        var current: [String] = []
        var count = 0

        for paragraph in paragraphs {
            let words = paragraph.split(whereSeparator: \.isWhitespace).count
            if count > 0, count + words > targetWordCount {
                chunks.append(current.joined(separator: "\n"))
                current = []
                count = 0
            }
            current.append(paragraph)
            count += words
        }

        if !current.isEmpty {
            chunks.append(current.joined(separator: "\n"))
        }

        if chunks.isEmpty {
            let words = text.split(whereSeparator: \.isWhitespace).map(String.init)
            stride(from: 0, to: words.count, by: targetWordCount).forEach { start in
                chunks.append(words[start..<min(start + targetWordCount, words.count)].joined(separator: " "))
            }
        }

        return chunks
    }
}
