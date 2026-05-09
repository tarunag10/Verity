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

                Button("Summarize Current Scope") {
                    store.summarize()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(store.chunks.isEmpty)
            }

            CommandMenu("Verity") {
                Button("Run Evaluation") {
                    store.runEvaluation()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .disabled(store.chunks.isEmpty)
            }
        }

        Settings {
            SettingsCenterView(store: store)
                .frame(width: 620)
        }
    }
}
