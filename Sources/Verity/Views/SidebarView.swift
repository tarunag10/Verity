import SwiftUI
import VerityCore

struct SidebarView: View {
    @ObservedObject var store: LibraryStore
    @Binding var selection: AppSection?

    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                Label("Documents", systemImage: "doc.text.magnifyingglass")
                    .tag(AppSection.documents)

                Label("Templates", systemImage: "tablecells")
                    .tag(AppSection.templates)

                Label("Evaluation", systemImage: "checklist.checked")
                    .tag(AppSection.evaluation)

                Label("Settings", systemImage: store.privacySettings.localOnlyMode ? "lock.shield" : "gearshape")
                    .tag(AppSection.settings)
            }

            Section("Chats") {
                ForEach(store.chats) { chat in
                    ChatRow(chat: chat)
                        .tag(AppSection.chat(chat.id))
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Button {
                store.newChat()
                selection = store.activeChatID.map(AppSection.chat)
            } label: {
                Label("New Chat", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .padding(12)
        }
    }
}

private struct ChatRow: View {
    let chat: ChatThread

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "message")
                .foregroundStyle(.secondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.title)
                    .lineLimit(1)
                Text(chat.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
