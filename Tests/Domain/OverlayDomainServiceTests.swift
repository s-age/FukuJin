import XCTest
@testable import FukuJin

final class OverlayDomainServiceTests: XCTestCase {
    private var pinService: PinDomainServiceMock!
    private var actionService: WindowActionDomainServiceMock!
    private var discoveryService: WindowDiscoveryDomainServiceMock!
    private var sut: OverlayDomainService!

    override func setUp() {
        super.setUp()
        pinService = PinDomainServiceMock()
        actionService = WindowActionDomainServiceMock()
        discoveryService = WindowDiscoveryDomainServiceMock()
        sut = OverlayDomainService(
            pinService: pinService,
            actionService: actionService,
            discoveryService: discoveryService,
            policy: OverlayPolicyDomainService()
        )
    }

    override func tearDown() {
        pinService = nil
        actionService = nil
        discoveryService = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - activate

    func test_activate_raisesRealWindowOnce() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 7)
        XCTAssertEqual(actionService.raiseWindowCallCount, 1)
    }

    func test_activate_raisesWithResolvedPID() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 7)
        XCTAssertEqual(actionService.lastRaisePID, 100)
    }

    func test_activate_makesActivatedWindowTheAnchor() {
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        let plan = sut.activate(windowID: 7)
        XCTAssertEqual(plan.anchorWindowID, 7)
    }

    func test_activate_pausesCaptureForActivatedWindow() {
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        let plan = sut.activate(windowID: 7)
        XCTAssertEqual(plan.placements.first { $0.windowID == 7 }?.isCaptureActive, false)
    }

    func test_activate_unknownWindow_doesNotRaise() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 999)
        XCTAssertEqual(actionService.raiseWindowCallCount, 0)
    }

    // MARK: - sync(activationPID:)

    func test_sync_activation_observedPinnedWindow_becomesAnchor() {
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        discoveryService.stubbedFrontmostWindowID = 8
        let plan = sut.sync(activationPID: 100)
        XCTAssertEqual(plan.anchorWindowID, 8)
    }

    func test_sync_activation_observedNonPinnedWindow_noAnchor() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        discoveryService.stubbedFrontmostWindowID = 999  // not pinned
        let plan = sut.sync(activationPID: 100)
        XCTAssertNil(plan.anchorWindowID)
    }

    func test_sync_activation_resolvesFrontmostForActivatedPID() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.sync(activationPID: 100)
        XCTAssertEqual(discoveryService.lastFrontmostOwnerPID, 100)
    }

    // MARK: - lag guard end-to-end (regression fix)

    func test_sync_lagGuard_keepsAnchorWhenSameAppReactivatesWithEmptyObservation() {
        // Focus window 7 (pid 100), then the same app re-activates but CGWindowList hasn't surfaced
        // it yet (observed nil). The anchor must remain 7 so the overlay does not re-cover it.
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        _ = sut.activate(windowID: 7)
        discoveryService.stubbedFrontmostWindowID = nil
        let plan = sut.sync(activationPID: 100)
        XCTAssertEqual(plan.anchorWindowID, 7)
    }

    func test_sync_differentAppActivation_clearsAnchor() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 7)
        discoveryService.stubbedFrontmostWindowID = nil
        let plan = sut.sync(activationPID: 200)  // different app
        XCTAssertNil(plan.anchorWindowID)
    }

    // MARK: - sync(nil) keeps current focus

    func test_syncNil_retainsCurrentFocusWithoutQueryingDiscovery() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 7)
        let plan = sut.sync(activationPID: nil)
        XCTAssertEqual(plan.anchorWindowID, 7)
    }

    func test_syncNil_doesNotQueryDiscovery() {
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.sync(activationPID: nil)
        XCTAssertEqual(discoveryService.frontmostWindowIDCallCount, 0)
    }

    // MARK: - focus liveness (disappearance variant — the authority absorbs staleness)

    func test_syncNil_focusedWindowUnpinned_clearsAnchor() {
        // Focus 7, then 7 is unpinned out-of-band (the unpin path mutates pin state directly, then
        // the VM calls sync(nil)). The authority must clear the now-dead focus.
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        _ = sut.activate(windowID: 7)
        pinService.stubbedState = Self.list([(8, pid: 100)])  // 7 unpinned
        let plan = sut.sync(activationPID: nil)
        XCTAssertNil(plan.anchorWindowID)
    }

    func test_syncActivation_unpinnedFocusSameAppReactivates_doesNotResurrectFocus() {
        // The lag guard would keep an explicit focus on a same-app empty observation, but the
        // window is gone — liveness re-validation must override and clear it.
        pinService.stubbedState = Self.list([(7, pid: 100), (8, pid: 100)])
        _ = sut.activate(windowID: 7)
        pinService.stubbedState = Self.list([(8, pid: 100)])  // 7 unpinned
        discoveryService.stubbedFrontmostWindowID = nil
        let plan = sut.sync(activationPID: 100)
        XCTAssertNil(plan.anchorWindowID)
    }

    func test_activate_vanishedTargetMatchingStaleFocus_clearsAnchor() {
        // Activating a window that is no longer pinned reports it as unpinned; if it was the
        // current focus, the anchor clears rather than lingering.
        pinService.stubbedState = Self.list([(7, pid: 100)])
        _ = sut.activate(windowID: 7)
        pinService.stubbedState = .empty  // 7 unpinned
        let plan = sut.activate(windowID: 7)
        XCTAssertNil(plan.anchorWindowID)
    }

    // MARK: - Helpers

    private static func list(_ specs: [(id: UInt32, pid: Int32)]) -> PinnedWindowList {
        var list = PinnedWindowList.empty
        for spec in specs {
            list = list.pinning(
                WindowInfo(id: spec.id, ownerPID: spec.pid, ownerName: "App", windowName: "W\(spec.id)"),
                seed: .default
            )
        }
        return list
    }
}
