import AppKit
import Foundation
import PDFKit

public enum DocumentParserError: Error, LocalizedError {
    case unsupportedFileType(String)
    case unreadableFile(URL)

    public var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let type):
            "Verity does not support .\(type) files in this MVP yet."
        case .unreadableFile(let url):
            "Could not read \(url.lastPathComponent)."
        }
    }
}

public struct DocumentParser: Sendable {
    public init() {}

    public func parse(fileURL: URL) throws -> ParsedDocument {
        let type = fileURL.pathExtension.lowercased()
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path(percentEncoded: false))
        let createdAt = attributes?[.creationDate] as? Date
        let modifiedAt = attributes?[.modificationDate] as? Date

        let pages: [ParsedPage]
        switch type {
        case "pdf":
            pages = try parsePDF(fileURL)
        case "txt", "md", "markdown":
            pages = [ParsedPage(pageNumber: 1, text: try readUTF8(fileURL))]
        case "rtf":
            pages = [ParsedPage(pageNumber: 1, text: try readRTF(fileURL))]
        default:
            throw DocumentParserError.unsupportedFileType(type.isEmpty ? "unknown" : type)
        }

        let usefulTextCount = pages.map(\.text).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines).count
        let quality: TextQuality = usefulTextCount == 0 ? .imageOnly : usefulTextCount < 40 ? .lowText : .selectableText
        let status: DocumentStatus = quality == .imageOnly ? .ocrNeeded : .ready
        let metadata = DocumentMetadata(
            fileName: fileURL.lastPathComponent,
            fileURL: fileURL,
            fileType: type,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            pageCount: max(pages.count, 1),
            status: status
        )

        return ParsedDocument(metadata: metadata, pages: pages, textQuality: quality, status: status)
    }

    private func parsePDF(_ url: URL) throws -> [ParsedPage] {
        guard let document = PDFDocument(url: url) else {
            throw DocumentParserError.unreadableFile(url)
        }

        return (0..<document.pageCount).map { index in
            let text = document.page(at: index)?.string ?? ""
            return ParsedPage(pageNumber: index + 1, text: text)
        }
    }

    private func readUTF8(_ url: URL) throws -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw DocumentParserError.unreadableFile(url)
        }
    }

    private func readRTF(_ url: URL) throws -> String {
        do {
            let attributed = try NSAttributedString(url: url, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
            return attributed.string
        } catch {
            throw DocumentParserError.unreadableFile(url)
        }
    }
}
