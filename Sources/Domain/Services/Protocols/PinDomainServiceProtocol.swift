protocol PinDomainServiceProtocol: Sendable {
    func pin(_ window: WindowInfo, config: OverlayConfig) -> PinnedWindowList
    func unpin(_ windowID: UInt32) -> PinnedWindowList
    func unpinAll() -> PinnedWindowList
    func mutateWindow(
        windowID: UInt32,
        transform: @Sendable (PinnedWindow) throws -> PinnedWindow
    ) throws -> PinnedWindowList
    func currentState() -> PinnedWindowList
    func prune(keeping activeIDs: Set<UInt32>) -> PinnedWindowList
    func defaultConfig() -> OverlayConfig
    func updateDefaultConfig(_ config: OverlayConfig) throws -> OverlayConfig
    func reorder(_ newOrder: [UInt32]) -> PinnedWindowList
}
