protocol WindowDiscoveryDomainServiceProtocol: Sendable {
    func discoverWindows() -> [WindowInfo]
    func groupByApp(_ windows: [WindowInfo]) -> [WindowGroup]
    /// The window ID of the frontmost on-screen window owned by `pid` (topmost in CoreGraphics
    /// z-order among that app's windows). Scoping to the owning app is deliberate: it keeps the
    /// result stable when an unrelated app — including our own menu/settings — is active, where
    /// a global "topmost window" would otherwise leak a background window into the result.
    /// `nil` when that app has no eligible window on screen.
    func frontmostWindowID(ownedBy pid: Int32) -> UInt32?
}
