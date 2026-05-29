import AppKit
import CoreGraphics
import CoreMedia
@preconcurrency import ScreenCaptureKit
import Synchronization

final class CaptureDataSource: CaptureDataSourceProtocol, Sendable {
    private struct StreamState: Sendable {
        let stream: SCStream
        let output: WindowStreamCapture
        let width: Int
        let height: Int
    }

    private let streams: Mutex<[UInt32: StreamState]>
    private let continuations: Mutex<[UInt32: AsyncStream<CGImage>.Continuation]>

    init() {
        streams = Mutex([:])
        continuations = Mutex([:])
    }

    func observeFrames(windowID: UInt32) -> AsyncStream<CGImage> {
        let (stream, continuation) = AsyncStream<CGImage>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        continuations.withLock { dict in
            dict[windowID]?.finish()
            dict[windowID] = continuation
        }
        return stream
    }

    func startCapture(windowID: UInt32, fps: Double) async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let window = content.windows.first(where: { $0.windowID == windowID }) else {
            throw InfrastructureError.windowNotFound(windowID: windowID)
        }

        let scaleFactor = await Self.scaleFactor(for: window.frame)
        let width = Int(window.frame.width * scaleFactor)
        let height = Int(window.frame.height * scaleFactor)

        let filter = SCContentFilter(desktopIndependentWindow: window)
        let config = SCStreamConfiguration()
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(fps))
        config.width = width
        config.height = height
        config.queueDepth = 3
        config.showsCursor = false
        config.pixelFormat = kCVPixelFormatType_32BGRA

        let output = WindowStreamCapture(
            onFrameEmitted: { [weak self] image in
                self?.continuations.withLock { dict in
                    _ = dict[windowID]?.yield(image)
                }
            },
            onStopped: { [weak self] in
                self?.continuations.withLock { dict in
                    dict.removeValue(forKey: windowID)?.finish()
                }
            }
        )
        let stream = SCStream(filter: filter, configuration: config, delegate: output)
        try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: .global())
        try await stream.startCapture()

        streams.withLock { $0[windowID] = StreamState(stream: stream, output: output, width: width, height: height) }

        for _ in 0..<20 {
            if captureWindow(windowID) != nil { return }
            try await Task.sleep(for: .milliseconds(50))
        }
    }

    func stopCapture(windowID: UInt32) async {
        continuations.withLock { $0.removeValue(forKey: windowID)?.finish() }
        guard let state = streams.withLock({ $0.removeValue(forKey: windowID) }) else { return }
        try? await state.stream.stopCapture()
    }

    func updateFPS(windowID: UInt32, fps: Double) async throws {
        guard let state = streams.withLock({ $0[windowID] }) else { return }
        let config = SCStreamConfiguration()
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(fps))
        config.width = state.width
        config.height = state.height
        config.queueDepth = 3
        config.showsCursor = false
        config.pixelFormat = kCVPixelFormatType_32BGRA
        try await state.stream.updateConfiguration(config)
    }

    func captureWindow(_ windowID: UInt32) -> CGImage? {
        streams.withLock { $0[windowID]?.output.latestFrame }
    }

    func captureWindowOneShot(_ windowID: UInt32) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let window = content.windows.first(where: { $0.windowID == windowID }) else {
            throw InfrastructureError.windowNotFound(windowID: windowID)
        }
        let scaleFactor = await Self.scaleFactor(for: window.frame)
        let filter = SCContentFilter(desktopIndependentWindow: window)
        let config = SCStreamConfiguration()
        config.width = Int(window.frame.width * scaleFactor)
        config.height = Int(window.frame.height * scaleFactor)
        config.showsCursor = false
        config.pixelFormat = kCVPixelFormatType_32BGRA
        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }

    /// Resolves the backing scale factor of the display the window sits on, instead of assuming
    /// the main display's scale. `SCWindow.frame` is in the Core Graphics global space (top-left
    /// origin), so each `NSScreen.frame` (AppKit, bottom-left origin) is flipped into that space
    /// before computing the overlap. The screen with the largest intersection wins; falls back to
    /// the main screen's scale (then 1.0) when nothing intersects.
    private static func scaleFactor(for frame: CGRect) async -> CGFloat {
        await MainActor.run {
            let screens = NSScreen.screens
            guard let primaryHeight = screens.first?.frame.height else {
                return NSScreen.main?.backingScaleFactor ?? 1.0
            }
            var bestScreen: NSScreen?
            var bestArea: CGFloat = 0
            for screen in screens {
                let appKitFrame = screen.frame
                let cgFrame = CGRect(
                    x: appKitFrame.origin.x,
                    y: primaryHeight - appKitFrame.origin.y - appKitFrame.height,
                    width: appKitFrame.width,
                    height: appKitFrame.height
                )
                let overlap = cgFrame.intersection(frame)
                let area = overlap.isNull ? 0 : overlap.width * overlap.height
                if area > bestArea {
                    bestArea = area
                    bestScreen = screen
                }
            }
            return (bestScreen ?? NSScreen.main)?.backingScaleFactor ?? 1.0
        }
    }

    func getWindowBounds(_ windowID: UInt32) -> CGRect? {
        guard let list = CGWindowListCopyWindowInfo(
            [.optionIncludingWindow], windowID
        ) as? [[String: Any]],
              let info = list.first,
              let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary)
        else {
            return nil
        }
        return bounds
    }

    func preflightCaptureAccess() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    func requestCaptureAccess() {
        CGRequestScreenCaptureAccess()
    }
}
