import Foundation

protocol AppIconDomainServiceProtocol: Sendable {
    /// Returns PNG-encoded icon bytes for a running application, identified by
    /// bundle identifier and/or localized name. Returns nil if no running app
    /// matches or no icon is available.
    func appIcon(bundleIdentifier: String?, localizedName: String?) -> Data?
}
