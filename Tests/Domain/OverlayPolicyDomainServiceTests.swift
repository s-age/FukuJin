import XCTest
@testable import FukuJin

final class OverlayPolicyDomainServiceTests: XCTestCase {
    private var sut: OverlayPolicyDomainService!

    override func setUp() {
        super.setUp()
        sut = OverlayPolicyDomainService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - no frontmost pin (all float)

    func test_plan_focusNone_anchorIsNil() {
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.8)]), focus: .none)
        XCTAssertNil(plan.anchorWindowID)
    }

    func test_plan_focusNone_allCaptureActive() {
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.8)]), focus: .none)
        XCTAssertEqual(plan.placements.map(\.isCaptureActive), [true, true])
    }

    func test_plan_preservesPinOrder() {
        let plan = sut.plan(pinnedWindows: Self.list([(3, 0.5), (1, 0.5), (2, 0.5)]), focus: .none)
        XCTAssertEqual(plan.placements.map(\.windowID), [3, 1, 2])
    }

    func test_plan_preservesOpacityPerWindow() {
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.3), (2, 0.9)]), focus: .none)
        XCTAssertEqual(plan.placements.map(\.opacity), [0.3, 0.9])
    }

    // MARK: - a pinned window is frontmost (anchor)

    func test_plan_frontmostPinned_setsAnchor() {
        let focus = WindowFocusState.focused(windowID: 2, ownerPID: 100, origin: .explicit)
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.5)]), focus: focus)
        XCTAssertEqual(plan.anchorWindowID, 2)
    }

    func test_plan_frontmostPinned_anchorOverlayPausesCapture() {
        let focus = WindowFocusState.focused(windowID: 2, ownerPID: 100, origin: .explicit)
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.5)]), focus: focus)
        XCTAssertEqual(plan.placements.first { $0.windowID == 2 }?.isCaptureActive, false)
    }

    func test_plan_frontmostPinned_othersKeepCapturing() {
        let focus = WindowFocusState.focused(windowID: 2, ownerPID: 100, origin: .explicit)
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.5)]), focus: focus)
        XCTAssertEqual(plan.placements.first { $0.windowID == 1 }?.isCaptureActive, true)
    }

    func test_plan_frontmostPinned_anchorOverlayNotRemoved() {
        // z-order inversion (not removal): the active pin's overlay stays in the plan.
        let focus = WindowFocusState.focused(windowID: 2, ownerPID: 100, origin: .explicit)
        let plan = sut.plan(pinnedWindows: Self.list([(1, 0.5), (2, 0.5)]), focus: focus)
        XCTAssertTrue(plan.placements.contains { $0.windowID == 2 })
    }

    // NOTE: stale focus (a `.focused` window that is no longer pinned) is no longer the policy's
    // concern — the focus authority in `OverlayDomainService` clears it via a `windowUnpinned`
    // transition before calling `plan`, so `plan` is a pure liveness-assuming derivation. That
    // invariant is covered by `OverlayDomainServiceTests`.

    // MARK: - Helpers

    private static func list(_ specs: [(id: UInt32, opacity: Double)]) -> PinnedWindowList {
        var list = PinnedWindowList.empty
        for spec in specs {
            list = list.pinning(
                WindowInfo(id: spec.id, ownerPID: 100, ownerName: "App", windowName: "W\(spec.id)"),
                seed: OverlayConfig.create(opacity: spec.opacity, fps: 1)
            )
        }
        return list
    }
}
