import AppKit

protocol WorkspaceDataSourceProtocol: Sendable {
    func observeAppActivation() -> AsyncStream<Int32>
    func frontmostApplicationPID() -> Int32?
    func activateApp(pid: Int32)
    /// PNG-encoded bytes of the running app's icon, or nil if no running app
    /// matches or the icon cannot be converted to PNG.
    func appIcon(for bundleIdentifier: String?, localizedName: String?) -> Data?
}
