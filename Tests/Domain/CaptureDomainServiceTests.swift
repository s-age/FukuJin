import Foundation
import XCTest
@testable import FukuJin

final class CaptureDomainServiceTests: XCTestCase {
    private var sut: CaptureDomainService!
    private var mockRepository: CaptureRepositoryMock!

    override func setUp() {
        super.setUp()
        mockRepository = CaptureRepositoryMock()
        sut = CaptureDomainService(
            lifecycleRepository: mockRepository,
            snapshotRepository: mockRepository,
            permissionRepository: mockRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_capture_returnsCapturedImage_whenRepositoryReturnsOne() {
        let entity = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: BoundingBox(x: 1, y: 2, width: 3, height: 4))
        mockRepository.stubbedCaptureWindowResult = entity
        XCTAssertEqual(sut.capture(windowID: 1), entity)
    }

    func test_capture_returnsNil_whenRepositoryReturnsNil() {
        mockRepository.stubbedCaptureWindowResult = nil
        XCTAssertNil(sut.capture(windowID: 1))
    }

    func test_capture_forwardsWindowID() {
        _ = sut.capture(windowID: 42)
        XCTAssertEqual(mockRepository.lastWindowID, 42)
    }

    func test_captureOneShot_returnsCapturedImage() async throws {
        let entity = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: BoundingBox(x: 5, y: 6, width: 7, height: 8))
        mockRepository.stubbedCaptureWindowOneShotResult = entity
        let result = try await sut.captureOneShot(windowID: 1)
        XCTAssertEqual(result, entity)
    }

    func test_captureOneShot_forwardsWindowID() async throws {
        _ = try await sut.captureOneShot(windowID: 42)
        XCTAssertEqual(mockRepository.lastWindowID, 42)
    }

    func test_observeFrames_yieldsCapturedImageForEachRepositoryFrame() async throws {
        let entity = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: BoundingBox(x: 0, y: 0, width: 1, height: 1))
        mockRepository.stubbedObserveFrames = AsyncStream { continuation in
            continuation.yield(entity)
            continuation.finish()
        }
        let stream = sut.observeFrames(windowID: 1)
        var collected: [CapturedImageRef] = []
        for await frame in stream { collected.append(frame) }
        XCTAssertEqual(collected, [entity])
    }

    func test_startCapture_forwardsWindowID() async throws {
        try await sut.startCapture(windowID: 7, fps: 30)
        XCTAssertEqual(mockRepository.lastWindowID, 7)
    }

    func test_startCapture_forwardsFPS() async throws {
        try await sut.startCapture(windowID: 7, fps: 30)
        XCTAssertEqual(mockRepository.lastFPS, 30)
    }

    func test_stopCapture_callsRepositoryOnce() async {
        await sut.stopCapture(windowID: 9)
        XCTAssertEqual(mockRepository.stopCaptureCallCount, 1)
    }
}
