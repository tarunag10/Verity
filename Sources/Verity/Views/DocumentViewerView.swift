import AppKit
import PDFKit
import SwiftUI
import VerityCore

struct DocumentViewerView: View {
    let source: SourceReference
    let close: () -> Void
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            context
            Divider()
            bodyContent
        }
        .frame(minWidth: 360)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: source.fileType == "pdf" ? "doc.richtext" : "doc.plaintext")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(source.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(pageLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                NSWorkspace.shared.open(source.fileURL)
            } label: {
                Label("Open", systemImage: "arrow.up.forward.app")
            }

            Button {
                close()
            } label: {
                Image(systemName: "xmark")
                    .accessibilityLabel("Close source viewer")
            }
        }
        .padding()
    }

    private var context: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Citation context", systemImage: "quote.bubble")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(source.snippet)
                .font(.callout)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Search this document", text: $searchText)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }

    @ViewBuilder
    private var bodyContent: some View {
        if source.fileType == "pdf" {
            PDFSourceView(url: source.fileURL, pageNumber: source.pageNumber)
        } else {
            TextSourceView(url: source.fileURL, query: searchText)
        }
    }

    private var pageLabel: String {
        if let pageNumber = source.pageNumber {
            return "\(source.fileType.uppercased()) - Page \(pageNumber)"
        }
        return "\(source.fileType.uppercased()) - Document source"
    }
}

private struct PDFSourceView: NSViewRepresentable {
    let url: URL
    let pageNumber: Int?

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .textBackgroundColor
        return view
    }

    func updateNSView(_ view: PDFView, context: Context) {
        if view.document?.documentURL != url {
            view.document = PDFDocument(url: url)
        }

        guard let pageNumber,
              let document = view.document,
              pageNumber > 0,
              pageNumber <= document.pageCount,
              let page = document.page(at: pageNumber - 1) else {
            return
        }

        view.go(to: page)
    }
}

private struct TextSourceView: View {
    let url: URL
    let query: String

    private var text: String {
        if url.pathExtension.lowercased() == "rtf",
           let attributed = try? NSAttributedString(url: url, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            return attributed.string
        }

        return (try? String(contentsOf: url, encoding: .utf8)) ?? "Verity could not read this source file."
    }

    private var displayedText: String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        let lines = text
            .components(separatedBy: .newlines)
            .filter { $0.localizedCaseInsensitiveContains(trimmed) }

        return lines.isEmpty ? "No matches for \"\(trimmed)\"." : lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            Text(displayedText)
                .font(.system(.body, design: .serif))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
    }
}
