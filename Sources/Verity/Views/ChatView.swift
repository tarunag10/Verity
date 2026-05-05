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
        VStack(spacing: 0) {
            toolbar
            Divider()
            messageList
            Divider()
            composer
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
                .foregroundStyle(.secondary)
                .lineLimit(1)

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
                .foregroundStyle(.secondary)
            Text("Ask Verity what your documents say.")
                .font(.title2.weight(.semibold))
            Text("Answers are assembled from local passages and include citations you can open in one click.")
                .foregroundStyle(.secondary)
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

            Button {
                send()
            } label: {
                Label("Send", systemImage: "paperplane.fill")
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.chunks.isEmpty)
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
        guard let url = store.documentURL(for: citation.documentID) else { return }
        NSWorkspace.shared.open(url)
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
                    .foregroundStyle(.secondary)
                Spacer()
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(citation.documentName)\(citation.pageNumber.map { " - Page \($0)" } ?? "")")
                                        .font(.caption.weight(.semibold))
                                    Text(citation.snippet)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(14)
        .frame(maxWidth: 740, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(message.role == .user ? Color.blue.opacity(0.10) : Color(nsColor: .controlBackgroundColor))
        }
    }
}
