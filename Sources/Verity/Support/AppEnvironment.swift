import Foundation

enum AppEnvironment {
    static var storageDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
        return base.appending(path: "Verity", directoryHint: .isDirectory)
    }
}
