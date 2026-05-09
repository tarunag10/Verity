import SwiftUI
import VerityCore

struct CollectionsView: View {
    @ObservedObject var store: LibraryStore
    @State private var selectedCollectionID: UUID?
    @State private var newCollectionName = ""

    private var selectedCollection: DocumentCollection? {
        if let selectedCollectionID {
            return store.collections.first { $0.id == selectedCollectionID }
        }
        return store.collections.first
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HSplitView {
                collectionList
                    .frame(minWidth: 260, idealWidth: 300)
                collectionDetail
                    .frame(minWidth: 520)
            }
        }
        .navigationTitle("Collections")
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Document Collections")
                    .font(.headline)
                Text("Group local documents into project scopes for chat, templates, and review.")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            Spacer()
            TextField("New collection", text: $newCollectionName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 220)
            Button {
                let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                let collection = store.createCollection(name: name)
                selectedCollectionID = collection.id
                newCollectionName = ""
            } label: {
                Label("Create", systemImage: "plus")
            }
            .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    private var collectionList: some View {
        List(selection: $selectedCollectionID) {
            if store.collections.isEmpty {
                Text("Create a collection to start grouping documents.")
                    .font(.caption)
                    .foregroundStyle(.primary)
            } else {
                ForEach(store.collections) { collection in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(collection.name)
                            .lineLimit(1)
                        Text("\(collection.documentIDs.count) documents")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(collection.name), \(collection.documentIDs.count) documents")
                    .tag(collection.id)
                }
            }
        }
    }

    @ViewBuilder
    private var collectionDetail: some View {
        if let collection = selectedCollection {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(collection.name)
                            .font(.title3.weight(.semibold))
                        Text(collection.summary.isEmpty ? "Project scope for local document workflows." : collection.summary)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Documents") {
                    ForEach(store.documents) { document in
                        Toggle(isOn: documentBinding(document.id, collectionID: collection.id)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(document.fileName)
                                    .lineLimit(1)
                                Text(document.fileType.uppercased())
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .accessibilityLabel("\(document.fileName), \(document.fileType.uppercased())")
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "No Collections",
                systemImage: "folder",
                description: Text("Create a collection to scope chats and workflows around a project, client, or research topic.")
            )
        }
    }

    private func documentBinding(_ documentID: UUID, collectionID: UUID) -> Binding<Bool> {
        Binding {
            store.documentScope(forCollection: collectionID).contains(documentID)
        } set: { isSelected in
            if isSelected {
                store.addDocument(documentID, toCollection: collectionID)
            } else {
                store.removeDocument(documentID, fromCollection: collectionID)
            }
        }
    }
}
