import Foundation
import XCTest
@testable import FukuJin

final class ObserveCaptureFramesUseCaseTests: XCTestCase {
    private var sut: ObserveCaptureFramesUseCase!
    private var mockService: CaptureDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = CaptureDomainServiceMock()
        sut = ObserveCaptureFramesUseCase(captureService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func test_execute_callsObserveFramesOnce() throws {
        _ = try sut.execute(ObserveCaptureFramesRequest(windowID: 7))
        XCTAssertEqual(mockService.observeFramesCallCount, 1)
    }

    func test_execute_forwardsWindowID() throws {
        _ = try sut.execute(ObserveCaptureFramesRequest(windowID: 7))
        XCTAssertEqual(mockService.lastWindowID, 7)
    }

    func test_execute_yieldsCaptureResponseForEachEntity() async throws {
        let entity = CapturedImageRef(resolution: .streaming, windowID: 33, bounds: BoundingBox(x: 5, y: 6, width: 7, height: 8))
        mockService.stubbedObserveFrames = AsyncStream { continuation in
            continuation.yield(entity)
            continuation.finish()
        }
        let stream = try sut.execute(ObserveCaptureFramesRequest(windowID: 1))
        var collected: [CaptureResponse] = []
        for await frame in stream { collected.append(frame) }
        XCTAssertEqual(collected.map(\.image.windowID), [entity.windowID])
    }

    func test_execute_terminatesWhenServiceStreamFinishes() async throws {
        mockService.stubbedObserveFrames = AsyncStream { $0.finish() }
        let stream = try sut.execute(ObserveCaptureFramesRequest(windowID: 1))
        var count = 0
        for await _ in stream { count += 1 }
        XCTAssertEqual(count, 0)
    }
}
