import XCTest
@testable import FukuJin

final class ActivatePinnedWindowUseCaseTests: XCTestCase {
    private var mockService: OverlayDomainServiceMock!
    private var sut: ActivatePinnedWindowUseCase!

    override func setUp() {
        super.setUp()
        mockService = OverlayDomainServiceMock()
        sut = ActivatePinnedWindowUseCase(overlayService: mockService)
    }

    override func tearDown() {
        mockService = nil
        sut = nil
        super.tearDown()
    }

    func test_execute_callsActivateOnce() throws {
        _ = try sut.execute(ActivatePinnedWindowRequest(windowID: 7))
        XCTAssertEqual(mockService.activateCallCount, 1)
    }

    func test_execute_forwardsWindowID() throws {
        _ = try sut.execute(ActivatePinnedWindowRequest(windowID: 7))
        XCTAssertEqual(mockService.lastActivateWindowID, 7)
    }

    func test_execute_mapsPlanToResponse() throws {
        mockService.stubbedPlan = OverlayPlan(
            anchorWindowID: 7,
            placements: [OverlayPlacement(windowID: 7, opacity: 0.5, fps: 1, isCaptureActive: false)]
        )
        let response = try sut.execute(ActivatePinnedWindowRequest(windowID: 7))
        XCTAssertEqual(response.anchorWindowID, 7)
    }

    func test_request_validate_rejectsZeroWindowID() {
        do {
            try ActivatePinnedWindowRequest(windowID: 0).validate()
            XCTFail("Expected validation error")
        } catch {
            guard case ValidationError.invalidWindowID = error else {
                return XCTFail("expected .invalidWindowID, got \(error)")
            }
        }
    }
}
