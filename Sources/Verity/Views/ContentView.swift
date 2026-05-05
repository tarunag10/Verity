import SwiftUI
import VerityCore

enum AppSection: Hashable {
    case documents
    case chat(UUID)
    case privacy
}

struct ContentView: View {
    @ObservedObject var store: LibraryStore
    @SceneStorage("selectedSection") private var selectedSectionData: String = "documents"

    private var selectedSection: Binding<AppSection?> {
        Binding {
            if selectedSectionData == "documents" { return .documents }
            if selectedSectionData == "privacy" { return .privacy }
            if let id = UUID(uuidString: selectedSectionData) { return .chat(id) }
            return .documents
        } set: { value in
            switch value {
            case .documents:
                selectedSectionData = "documents"
            case .privacy:
                selectedSectionData = "privacy"
            case .chat(let id):
                selectedSectionData = id.uuidString
                store.activeChatID = id
            case nil:
                selectedSectionData = "documents"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store, selection: selectedSection)
        } content: {
            DocumentListView(store: store)
        } detail: {
            detailView
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedSection.wrappedValue {
        case .privacy:
            PrivacySettingsView(store: store)
        default:
            ChatView(store: store)
        }
    }
}
