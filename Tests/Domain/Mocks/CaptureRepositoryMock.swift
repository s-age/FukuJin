import Foundation
import os
@testable import FukuJin

final class CaptureRepositoryMock:
    CaptureLifecycleRepositoryProtocol,
    CaptureSnapshotRepositoryProtocol,
    WindowBoundsRepositoryProtocol,
    CapturePermissionRepositoryProtocol,
    @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var startCaptureCallCount = 0
    private(set) var stopCaptureCallCount = 0
    private(set) var updateFPSCallCount = 0
    private(set) var captureWindowCallCount = 0
    private(set) var captureWindowOneShotCallCount = 0
    private(set) var getWindowBoundsCallCount = 0
    private(set) var ensureCaptureAccessCallCount = 0
    private(set) var observeFramesCallCount = 0

    private(set) var lastWindowID: UInt32?
    private(set) var lastFPS: Double?

    var stubbedCaptureWindowResult: CapturedImageRef?
    var stubbedCaptureWindowOneShotResult = CapturedImageRef(
        resolution: .oneShot(snapshotID: UUID()),
        windowID: 0,
        bounds: .zero
    )
    var captureWindowOneShotError: Error?
    var startCaptureError: Error?
    var stubbedWindowBounds: BoundingBox?
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
    }

    func captureWindow(_ windowID: UInt32) -> CapturedImageRef? {
        lock.withLock { _ in
            captureWindowCallCount += 1
            lastWindowID = windowID
        }
        return stubbedCaptureWindowResult
    }

    func captureWindowOneShot(_ windowID: UInt32) async throws -> CapturedImageRef {
        lock.withLock { _ in
            captureWindowOneShotCallCount += 1
            lastWindowID = windowID
        }
        if let error = captureWindowOneShotError { throw error }
        return stubbedCaptureWindowOneShotResult
    }

    func getWindowBounds(_ windowID: UInt32) -> BoundingBox? {
        lock.withLock { _ in
            getWindowBoundsCallCount += 1
            lastWindowID = windowID
        }
        return stubbedWindowBounds
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
