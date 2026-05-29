/// Imperative window mechanisms. These are **not** a second z-order authority competing with the
/// declarative `OverlayPlan` — `OverlayPlan` is the sole authority for overlay z-order *intent*
/// (anchor + pin-ordered placements). The two paths cannot be merged: realizing the order requires
/// the overlay NSWindows' CGS window numbers, which exist only in Presentation after the windows are
/// created — Domain may never see them (no AppKit/CGS import). So they stay split by responsibility:
/// - `orderWindow(_:below:)` is the CGS *mechanism* Presentation calls to realize the plan's implied
///   ordering on overlay windows; it is subordinate to the plan, never invoked to make an
///   independent z-order decision.
/// - `raiseWindow(_:pid:)` / `activateApp(pid:)` act on the *real source window* (Accessibility),
///   a disjoint set from the overlays; orthogonal to z-order, emitted only after focus state commits.
final class WindowActionDomainService: WindowActionDomainServiceProtocol, Sendable {
    private let accessibilityRepository: any AccessibilityRepositoryProtocol
    private let workspaceRepository: any WorkspaceRepositoryProtocol
    private let zOrderRepository: any WindowZOrderRepositoryProtocol

    init(
        accessibilityRepository: any AccessibilityRepositoryProtocol,
        workspaceRepository: any WorkspaceRepositoryProtocol,
        zOrderRepository: any WindowZOrderRepositoryProtocol
    ) {
        self.accessibilityRepository = accessibilityRepository
        self.workspaceRepository = workspaceRepository
        self.zOrderRepository = zOrderRepository
    }

    func raiseWindow(windowID: UInt32, pid: Int32) {
        workspaceRepository.activateApp(pid: pid)
        accessibilityRepository.raiseWindow(windowID: windowID, pid: pid)
    }

    func activateApp(pid: Int32) {
        workspaceRepository.activateApp(pid: pid)
    }

    func requestAccessibilityPermission() {
        accessibilityRepository.requestAccessibilityPermission()
    }

    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32) {
        zOrderRepository.orderWindow(windowID, below: relativeWindowID)
    }

    func observeAppActivation() -> AsyncStream<Int32> {
        workspaceRepository.observeAppActivation()
    }
}
