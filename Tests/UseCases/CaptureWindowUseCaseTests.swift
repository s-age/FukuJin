import Foundation
import XCTest
@testable import FukuJin

final class CaptureWindowUseCaseTests: XCTestCase {
    private var sut: CaptureWindowUseCase!
    private var mockService: CaptureDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = CaptureDomainServiceMock()
        sut = CaptureWindowUseCase(captureService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func test_execute_callsCaptureOnce() throws {
        _ = try sut.execute(CaptureWindowRequest(windowID: 5))
        XCTAssertEqual(mockService.captureCallCount, 1)
    }

    func test_execute_forwardsWindowID() throws {
        _ = try sut.execute(CaptureWindowRequest(windowID: 5))
        XCTAssertEqual(mockService.lastWindowID, 5)
    }

    func test_execute_returnsNilWhenServiceReturnsNil() throws {
        mockService.stubbedCaptureResult = nil
        let response = try sut.execute(CaptureWindowRequest(windowID: 5))
        XCTAssertNil(response)
    }

    func test_execute_mapsEntityToResponse_preservingWindowID() throws {
        mockService.stubbedCaptureResult = CapturedImageRef(
            resolution: .streaming,
            windowID: 73,
            bounds: BoundingBox(x: 0, y: 0, width: 10, height: 10)
        )
        let response = try sut.execute(CaptureWindowRequest(windowID: 5))
        XCTAssertEqual(response?.image.windowID, 73)
    }

    func test_execute_mapsEntityToResponse_preservingBounds() throws {
        mockService.stubbedCaptureResult = CapturedImageRef(
            resolution: .streaming,
            windowID: 5,
            bounds: BoundingBox(x: 1, y: 2, width: 3, height: 4)
        )
        let response = try sut.execute(CaptureWindowRequest(windowID: 5))
        XCTAssertEqual(response?.image.bounds, BoundingBoxResponse(x: 1, y: 2, width: 3, height: 4))
    }
}
