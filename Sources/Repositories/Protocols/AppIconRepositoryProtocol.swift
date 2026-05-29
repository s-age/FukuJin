import Foundation

protocol AppIconRepositoryProtocol: Sendable {
    /// PNG-encoded icon bytes for the running app matching either identifier,
    /// or nil if no match or icon conversion fails.
    func appIcon(for bundleIdentifier: String?, localizedName: String?) -> Data?
}
