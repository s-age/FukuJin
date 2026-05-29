import AppKit
import os
import XCTest
@testable import FukuJin

/// Records every `orderWindowBelow` request so the CGS anchor chain can be asserted in order.
final class RecordingOrderBelowStub: SyncUseCase, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<[OrderWindowBelowRequest]>(initialState: [])
    var requests: [OrderWindowBelowRequest] { lock.withLock { $0 } }

    func execute(_ request: OrderWindowBelowRequest) throws {
        lock.withLock { $0.append(request) }
    }
}

@MainActor
final class OverlayManagerTests: XCTestCase {
    private var syncStub: StubSyncUseCase<SyncOverlaysRequest, OverlayPlanResponse>!
    private var activateStub: StubSyncUseCase<ActivatePinnedWindowRequest, OverlayPlanResponse>!
    private var orderBelowSpy: RecordingOrderBelowStub!
    // Retains the frame-stream continuation so the stream stays open (a finished stream would trip
    // CaptureMonitor's termination path and tear the overlay down before we can assert).
    private var frameContinuation: AsyncStream<CaptureResponse>.Continuation?

    override func tearDown() {
        syncStub = nil
        activateStub = nil
        orderBelowSpy = nil
        frameContinuation = nil
        super.tearDown()
    }

    private func makeFrame() -> CaptureResponse {
        CaptureResponse(
            image: CapturedImageRefResponse(
                snapshotID: nil,
                windowID: 1,
                bounds: BoundingBoxResponse(x: 0, y: 0, width: 120, height: 80)
            )
        )
    }

    private func makeManager() -> OverlayManager {
        syncStub = StubSyncUseCase(stubbedResult: Self.plan(anchor: nil, []))
        activateStub = StubSyncUseCase(stubbedResult: Self.plan(anchor: nil, []))
        orderBelowSpy = RecordingOrderBelowStub()
        let openStream = AsyncStream<CaptureResponse> { self.frameContinuation = $0 }
        return OverlayManager(
            captureWindow: StubSyncUseCase<CaptureWindowRequest, CaptureResponse?>(stubbedResult: makeFrame()),
            manageCaptureStream: StubAsyncUseCase<ManageCaptureStreamRequest, Void>(stubbedResult: ()),
            orderWindowBelow: orderBelowSpy,
            observeCaptureFrames: StubSyncUseCase<ObserveCaptureFramesRequest, AsyncStream<CaptureResponse>>(
                stubbedResult: openStream
            ),
            resolver: CapturedImageResolverMock(),
            syncOverlays: syncStub,
            activatePinnedWindow: activateStub
        )
    }

    private static func plan(anchor: UInt32?, _ ids: [UInt32]) -> OverlayPlanResponse {
        OverlayPlanResponse(from: OverlayPlan(
            anchorWindowID: anchor,
            placements: ids.map {
                OverlayPlacement(windowID: $0, opacity: 0.5, fps: 1, isCaptureActive: $0 != anchor)
            }
        ))
    }

    private func waitForOverlays(_ manager: OverlayManager, ids: [UInt32]) async {
        var attempts = 0
        while !Set(ids).isSubset(of: manager.overlayWindowIDs) && attempts < 1000 {
            await Task.yield()
            attempts += 1
        }
    }

    // MARK: - create / destroy lifecycle

    func test_apply_createsOverlaysForPlacements() async {
        let manager = makeManager()
        manager.apply(Self.plan(anchor: nil, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])
        XCTAssertEqual(manager.overlayWindowIDs, [1, 2])
    }

    func test_apply_unpin_removesOnlyThatOverlay() async {
        let manager = makeManager()
        manager.apply(Self.plan(anchor: nil, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])

        manager.apply(Self.plan(anchor: nil, [1]))

        XCTAssertFalse(manager.overlayWindowIDs.contains(2))
    }

    func test_apply_focusChange_doesNotDestroyOverlays() async {
        // Regression-critical: when a pin becomes frontmost (anchor), its overlay is NOT removed —
        // it is z-ordered below its real window. Every overlay stays alive across focus changes.
        let manager = makeManager()
        manager.apply(Self.plan(anchor: nil, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])

        manager.apply(Self.plan(anchor: 1, [1, 2]))

        XCTAssertEqual(manager.overlayWindowIDs, [1, 2])
    }

    // MARK: - z-order

    func test_apply_floating_makesNoCGSBelowCalls() async {
        let manager = makeManager()
        manager.apply(Self.plan(anchor: nil, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])
        await Task.yield()  // let the post-creation drain ordering pass run

        XCTAssertTrue(orderBelowSpy.requests.isEmpty)
    }

    func test_apply_anchor_chainsNonActiveOverlaysBelowRealWindow() async {
        let manager = makeManager()
        manager.apply(Self.plan(anchor: 1, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])
        var attempts = 0
        while orderBelowSpy.requests.isEmpty && attempts < 1000 {
            await Task.yield()
            attempts += 1
        }

        // Window 2 is chained directly below the active pin's real window (CGWindowID 1).
        XCTAssertEqual(orderBelowSpy.requests.first?.relativeWindowID, 1)
    }

    func test_apply_anchor_doesNotChainTheActivePinsOwnOverlay() async {
        // The active pin (1) is hidden via orderOut, so only the one non-active overlay (2) is
        // CGS-chained — never the active pin's own overlay.
        let manager = makeManager()
        manager.apply(Self.plan(anchor: 1, [1, 2]))
        await waitForOverlays(manager, ids: [1, 2])
        var attempts = 0
        while orderBelowSpy.requests.isEmpty && attempts < 1000 {
            await Task.yield()
            attempts += 1
        }
        await Task.yield()

        XCTAssertEqual(orderBelowSpy.requests.count, 1)
    }

    // MARK: - sync drives the use case

    func test_sync_appliesPlanReturnedByUseCase() async {
        let manager = makeManager()
        syncStub.stubbedResult = Self.plan(anchor: nil, [7])

        manager.sync(activationPID: 100)
        await waitForOverlays(manager, ids: [7])

        XCTAssertTrue(manager.overlayWindowIDs.contains(7))
    }

    func test_sync_forwardsActivationPID() {
        let manager = makeManager()
        manager.sync(activationPID: 42)
        XCTAssertEqual(syncStub.lastRequest?.activationPID, 42)
    }
}
