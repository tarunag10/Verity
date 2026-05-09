import SwiftUI
import VerityCore

enum AppSection: Hashable {
    case documents
    case collections
    case templates
    case evaluation
    case settings
    case chat(UUID)
    case privacy
}

struct ContentView: View {
    @ObservedObject var store: LibraryStore
    @SceneStorage("selectedSection") private var selectedSectionData: String = "documents"

    private var selectedSection: Binding<AppSection?> {
        Binding {
            if selectedSectionData == "documents" { return .documents }
            if selectedSectionData == "collections" { return .collections }
            if selectedSectionData == "templates" { return .templates }
            if selectedSectionData == "evaluation" { return .evaluation }
            if selectedSectionData == "settings" { return .settings }
            if selectedSectionData == "privacy" { return .privacy }
            if let id = UUID(uuidString: selectedSectionData) { return .chat(id) }
            return .documents
        } set: { value in
            switch value {
            case .documents:
                selectedSectionData = "documents"
            case .collections:
                selectedSectionData = "collections"
            case .templates:
                selectedSectionData = "templates"
            case .evaluation:
                selectedSectionData = "evaluation"
            case .settings:
                selectedSectionData = "settings"
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
        case .collections:
            CollectionsView(store: store)
        case .templates:
            TemplatesView(store: store)
        case .evaluation:
            EvaluationView(store: store)
        case .settings, .privacy:
            SettingsCenterView(store: store)
        default:
            ChatView(store: store)
        }
    }
}
