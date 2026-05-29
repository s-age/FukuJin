import Foundation
import XCTest
@testable import FukuJin

final class CaptureWindowOneShotUseCaseTests: XCTestCase {
    private var sut: CaptureWindowOneShotUseCase!
    private var mockService: CaptureDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = CaptureDomainServiceMock()
        sut = CaptureWindowOneShotUseCase(captureService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func test_execute_callsCaptureOneShotOnce() async throws {
        _ = try await sut.execute(CaptureWindowOneShotRequest(windowID: 42))
        XCTAssertEqual(mockService.captureOneShotCallCount, 1)
    }

    func test_execute_forwardsWindowID() async throws {
        _ = try await sut.execute(CaptureWindowOneShotRequest(windowID: 42))
        XCTAssertEqual(mockService.lastWindowID, 42)
    }

    func test_execute_mapsDomainEntityToResponse_preservingSnapshotID() async throws {
        let entityID = UUID()
        mockService.stubbedCaptureOneShotResult = CapturedImageRef(
            resolution: .oneShot(snapshotID: entityID),
            windowID: 1,
            bounds: BoundingBox(x: 1, y: 2, width: 3, height: 4)
        )
        let response = try await sut.execute(CaptureWindowOneShotRequest(windowID: 1))
        XCTAssertEqual(response.snapshotID, entityID)
    }

    func test_execute_mapsDomainEntityToResponse_preservingBounds() async throws {
        mockService.stubbedCaptureOneShotResult = CapturedImageRef(
            resolution: .oneShot(snapshotID: UUID()),
            windowID: 1,
            bounds: BoundingBox(x: 10, y: 20, width: 30, height: 40)
        )
        let response = try await sut.execute(CaptureWindowOneShotRequest(windowID: 1))
        XCTAssertEqual(response.bounds, BoundingBoxResponse(x: 10, y: 20, width: 30, height: 40))
    }

    func test_execute_propagatesServiceError() async {
        struct StubError: Error {}
        mockService.captureOneShotError = StubError()
        do {
            _ = try await sut.execute(CaptureWindowOneShotRequest(windowID: 1))
            XCTFail("Expected error")
        } catch is StubError {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
