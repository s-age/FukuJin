import XCTest
@testable import FukuJin

final class SyncOverlaysUseCaseTests: XCTestCase {
    private var mockService: OverlayDomainServiceMock!
    private var sut: SyncOverlaysUseCase!

    override func setUp() {
        super.setUp()
        mockService = OverlayDomainServiceMock()
        sut = SyncOverlaysUseCase(overlayService: mockService)
    }

    override func tearDown() {
        mockService = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_callsSyncOnce() throws {
        _ = try sut.execute(SyncOverlaysRequest(activationPID: 100))
        XCTAssertEqual(mockService.syncCallCount, 1)
    }

    func test_execute_forwardsActivationPID() throws {
        _ = try sut.execute(SyncOverlaysRequest(activationPID: 100))
        XCTAssertEqual(mockService.lastSyncActivationPID, 100)
    }

    func test_execute_forwardsNilActivationPID() throws {
        _ = try sut.execute(SyncOverlaysRequest(activationPID: nil))
        XCTAssertNil(mockService.lastSyncActivationPID)
    }

    func test_execute_mapsPlanAnchorToResponse() throws {
        mockService.stubbedPlan = OverlayPlan(
            anchorWindowID: 7,
            placements: [OverlayPlacement(windowID: 8, opacity: 0.5, fps: 1, isCaptureActive: true)]
        )
        let response = try sut.execute(SyncOverlaysRequest(activationPID: nil))
        XCTAssertEqual(response.anchorWindowID, 7)
    }

    func test_execute_mapsPlacementsToResponse() throws {
        mockService.stubbedPlan = OverlayPlan(
            anchorWindowID: nil,
            placements: [OverlayPlacement(windowID: 8, opacity: 0.5, fps: 2, isCaptureActive: false)]
        )
        let response = try sut.execute(SyncOverlaysRequest(activationPID: nil))
        XCTAssertEqual(
            response.placements,
            [OverlayPlacementResponse(windowID: 8, opacity: 0.5, fps: 2, isCaptureActive: false)]
        )
    }
}
