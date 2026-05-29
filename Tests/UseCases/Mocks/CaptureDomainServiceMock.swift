import Foundation
import os
@testable import FukuJin

final class CaptureDomainServiceMock: CaptureDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var startCaptureCallCount = 0
    private(set) var stopCaptureCallCount = 0
    private(set) var updateFPSCallCount = 0
    private(set) var captureCallCount = 0
    private(set) var captureOneShotCallCount = 0
    private(set) var ensureCaptureAccessCallCount = 0
    private(set) var observeFramesCallCount = 0

    private(set) var lastWindowID: UInt32?
    private(set) var lastFPS: Double?

    var stubbedCaptureResult: CapturedImageRef?
    var stubbedCaptureOneShotResult = CapturedImageRef(
        resolution: .oneShot(snapshotID: UUID()),
        windowID: 0,
        bounds: .zero
    )
    var captureOneShotError: Error?
    var startCaptureError: Error?
    var updateFPSError: Error?
    var stubbedObserveFrames: AsyncStream<CapturedImageRef> = AsyncStream { $0.finish() }

    func startCapture(windowID: UInt32, fps: Double) async throws {
        lock.withLock { _ in
            startCaptureCallCount += 1
            lastWindowID = windowID
            lastFPS = fps
        }
        if let error = startCaptureError { throw error }
    }

    func stopCapture(windowID: UInt32) async {
        lock.withLock { _ in
            stopCaptureCallCount += 1
            lastWindowID = windowID
        }
    }

    func updateFPS(windowID: UInt32, fps: Double) async throws {
        lock.withLock { _ in
            updateFPSCallCount += 1
            lastWindowID = windowID
            lastFPS = fps
        }
        if let error = updateFPSError { throw error }
    }

    func capture(windowID: UInt32) -> CapturedImageRef? {
        lock.withLock { _ in
            captureCallCount += 1
            lastWindowID = windowID
        }
        return stubbedCaptureResult
    }

    func captureOneShot(windowID: UInt32) async throws -> CapturedImageRef {
        lock.withLock { _ in
            captureOneShotCallCount += 1
            lastWindowID = windowID
        }
        if let error = captureOneShotError { throw error }
        return stubbedCaptureOneShotResult
    }

    func ensureCaptureAccess() {
        lock.withLock { _ in ensureCaptureAccessCallCount += 1 }
    }

    func observeFrames(windowID: UInt32) -> AsyncStream<CapturedImageRef> {
        lock.withLock { _ in
            observeFramesCallCount += 1
            lastWindowID = windowID
        }
        return stubbedObserveFrames
    }
}
