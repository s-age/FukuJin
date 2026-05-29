import Foundation
import os

final class SettingsDataSource: SettingsDataSourceProtocol, Sendable {
    private static let logger = Logger(subsystem: "com.fukujin.app", category: "settings")

    private let fileURL: URL

    init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        let directory = appSupport.appendingPathComponent("com.fukujin.app", isDirectory: true)
        fileURL = directory.appendingPathComponent("defaults.json")
        Self.migrateLegacyStoreIfNeeded(to: fileURL)
    }

    func load() -> SettingsDTO? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SettingsDTO.self, from: data)
    }

    func save(_ dto: SettingsDTO) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(dto)
        let fileManager = FileManager.default
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        try data.write(to: fileURL, options: .atomic)
        try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
    }

    /// One-time migration from the legacy home-directory store (`~/.fuku-jin/defaults.json`,
    /// world-readable 0o644) to the Application Support location. Runs only when the new store
    /// is absent and the legacy file exists. Failures are logged but never block startup, since
    /// this path carries no user input.
    private static func migrateLegacyStoreIfNeeded(to newURL: URL) {
        let fileManager = FileManager.default
        let legacyURL = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent(".fuku-jin/defaults.json")
        guard fileManager.fileExists(atPath: legacyURL.path),
              !fileManager.fileExists(atPath: newURL.path) else { return }
        do {
            let directory = newURL.deletingLastPathComponent()
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: 0o700]
            )
            try fileManager.copyItem(at: legacyURL, to: newURL)
            try fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: newURL.path)
            try fileManager.removeItem(at: legacyURL)
        } catch {
            logger.warning("Settings migration failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
