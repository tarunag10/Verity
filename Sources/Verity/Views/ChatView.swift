import AppKit
import SwiftUI
import VerityCore

private enum ChatScopeMode: String, CaseIterable, Identifiable {
    case library = "Library"
    case selectedDocument = "Selected Document"

    var id: String { rawValue }
}

struct ChatView: View {
    @ObservedObject var store: LibraryStore
    @State private var prompt = ""
    @State private var scopeMode: ChatScopeMode = .library
    @State private var selectedSource: SourceReference?

    private var activeMessages: [ChatMessage] {
        store.activeChat?.messages ?? []
    }

    private var scope: Set<UUID> {
        if scopeMode == .selectedDocument, let selected = store.selectedDocumentID {
            return [selected]
        }
        return []
    }

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                toolbar
                Divider()
                messageList
                Divider()
                composer
            }
            .frame(minWidth: 460)

            if let selectedSource {
                DocumentViewerView(source: selectedSource) {
                    self.selectedSource = nil
                }
                .frame(minWidth: 380, idealWidth: 460)
            }
        }
        .navigationTitle("Chat")
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker("Scope", selection: $scopeMode) {
                ForEach(ChatScopeMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 260)
            .disabled(store.documents.isEmpty)

            Text(scopeDescription)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .accessibilityLabel("Chat scope: \(scopeDescription)")

            Spacer()

            Button {
                store.summarize(scope: scope)
            } label: {
                Label("Summarize", systemImage: "text.alignleft")
            }
            .disabled(store.chunks.isEmpty)

            Button(role: .destructive) {
                store.deleteActiveChat()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .padding()
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if activeMessages.isEmpty {
                    emptyState
                } else {
                    ForEach(activeMessages) { message in
                        MessageBubble(message: message, openCitation: openCitation)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.primary)
            Text("Ask Verity what your documents say.")
                .font(.title2.weight(.semibold))
            Text("Answers are assembled from local passages and include citations you can open in one click.")
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 520, alignment: .leading)
        .padding(.top, 80)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Ask about renewal terms, invoices, risks, manuals...", text: $prompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)
                .onSubmit(send)
                .accessibilityLabel("Ask Verity")
                .accessibilityHint("Type a question about your imported documents.")

            Button {
                send()
            } label: {
                Label("Send", systemImage: "paperplane.fill")
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.chunks.isEmpty)
            .accessibilityHint("Sends your question to the local document assistant.")
        }
        .padding()
    }

    private var scopeDescription: String {
        guard !store.documents.isEmpty else { return "Import a document to start." }
        if scopeMode == .selectedDocument {
            if let selected = store.selectedDocumentID,
               let document = store.documents.first(where: { $0.id == selected }) {
                return "Using \(document.fileName)"
            }
            return "Select a document in the library."
        }
        return "Using all ready documents."
    }

    private func send() {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.ask(trimmed, scope: scope)
        prompt = ""
    }

    private func openCitation(_ citation: Citation) {
        selectedSource = store.sourceReference(for: citation)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let openCitation: (Citation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(message.role == .user ? "You" : "Verity", systemImage: message.role == .user ? "person.crop.circle" : "sparkle.magnifyingglass")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text(message.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            Text(message.text)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            if !message.citations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(message.citations) { citation in
                        Button {
                            openCitation(citation)
                        } label: {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "quote.bubble")
                                    .foregroundStyle(.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(citation.documentName)\(citation.pageNumber.map { " - Page \($0)" } ?? "")")
                                        .font(.caption.weight(.semibold))
                                    Text(citation.snippet)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Citation from \(citation.documentName)\(citation.pageNumber.map { ", page \($0)" } ?? ""): \(citation.snippet)")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(10)
                .accessiblePanel()
            }
        }
        .padding(14)
        .frame(maxWidth: 740, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(message.role == .user ? 0.45 : 0.28), lineWidth: message.role == .user ? 2 : 1)
        }
        .accessibilityElement(children: .contain)
    }
}
