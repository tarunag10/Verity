import SwiftUI
import VerityCore

@main
struct VerityApp: App {
    @StateObject private var store = LibraryStore(storageDirectory: AppEnvironment.storageDirectory)

    var body: some Scene {
        WindowGroup("Verity") {
            ContentView(store: store)
                .frame(minWidth: 1040, minHeight: 680)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Chat") {
                    store.newChat()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }

        Settings {
            PrivacySettingsView(store: store)
                .frame(width: 520)
        }
    }
}
