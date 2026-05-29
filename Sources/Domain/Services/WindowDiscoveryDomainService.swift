final class WindowDiscoveryDomainService: WindowDiscoveryDomainServiceProtocol, Sendable {
    private let repository: any WindowRepositoryProtocol

    init(repository: any WindowRepositoryProtocol) {
        self.repository = repository
    }

    func discoverWindows() -> [WindowInfo] {
        repository.listVisibleWindows()
    }

    func frontmostWindowID(ownedBy pid: Int32) -> UInt32? {
        // `listVisibleWindows()` preserves CoreGraphics front-to-back z-order, so the first
        // window owned by `pid` is that app's topmost window. When `pid` owns nothing on screen
        // (e.g. our own app is active — its windows are filtered out), this is `nil`, which the
        // caller reads as "no pinned window is in front", keeping every overlay floating.
        repository.listVisibleWindows().first { $0.ownerPID == pid }?.id
    }

    func groupByApp(_ windows: [WindowInfo]) -> [WindowGroup] {
        WindowGroup.grouping(windows)
    }
}
