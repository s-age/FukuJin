import CoreGraphics
import Foundation
import os
@testable import FukuJin

final class CaptureDataSourceMock: CaptureDataSourceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var startCaptureCallCount = 0
    private(set) var lastStartCaptureWindowID: UInt32?
    private(set) var lastStartCaptureFPS: Double?
    var startCaptureError: Error?

    private(set) var captureWindowOneShotCallCount = 0
    private(set) var lastCaptureWindowOneShotID: UInt32?
    var captureWindowOneShotError: Error?
    var captureWindowOneShotResult: CGImage = CaptureDataSourceMock.makePlaceholderImage()

    func startCapture(windowID: UInt32, fps: Double) async throws {
        lock.withLock { _ in
            startCaptureCallCount += 1
            lastStartCaptureWindowID = windowID
            lastStartCaptureFPS = fps
        }
        if let error = startCaptureError { throw error }
    }

    func stopCapture(windowID: UInt32) async {}

    func updateFPS(windowID: UInt32, fps: Double) async throws {}

    func captureWindow(_ windowID: UInt32) -> CGImage? { nil }

    func captureWindowOneShot(_ windowID: UInt32) async throws -> CGImage {
        lock.withLock { _ in
            captureWindowOneShotCallCount += 1
            lastCaptureWindowOneShotID = windowID
        }
        if let error = captureWindowOneShotError { throw error }
        return captureWindowOneShotResult
    }

    func getWindowBounds(_ windowID: UInt32) -> CGRect? { nil }

    func preflightCaptureAccess() -> Bool { true }

    func requestCaptureAccess() {}

    func observeFrames(windowID: UInt32) -> AsyncStream<CGImage> {
        AsyncStream { $0.finish() }
    }

    private static func makePlaceholderImage() -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}
