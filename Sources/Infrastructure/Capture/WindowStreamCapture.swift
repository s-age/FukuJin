@preconcurrency import ScreenCaptureKit
import CoreMedia
import CoreGraphics
import Synchronization

final class WindowStreamCapture: NSObject,
                                 SCStreamOutput,
                                 SCStreamDelegate,
                                 Sendable {
    /// Device RGB color space is identical for every frame, so create it once at the type level
    /// instead of allocating a fresh `CGColorSpace` inside the per-frame pixel-buffer lock.
    private static let deviceRGB = CGColorSpaceCreateDeviceRGB()
    private static let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        | CGBitmapInfo.byteOrder32Little.rawValue

    private let frameStore: Mutex<CGImage?>
    private let onFrameEmitted: @Sendable (CGImage) -> Void
    private let onStopped: @Sendable () -> Void

    init(
        onFrameEmitted: @escaping @Sendable (CGImage) -> Void,
        onStopped: @escaping @Sendable () -> Void
    ) {
        frameStore = Mutex(nil)
        self.onFrameEmitted = onFrameEmitted
        self.onStopped = onStopped
        super.init()
    }

    var latestFrame: CGImage? {
        frameStore.withLock { $0 }
    }

    func clearFrame() {
        frameStore.withLock { $0 = nil }
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        guard let image = Self.extractImage(from: sampleBuffer) else { return }
        frameStore.withLock { $0 = image }
        onFrameEmitted(image)
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        frameStore.withLock { $0 = nil }
        onStopped()
    }

    private static func extractImage(from sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

        guard let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: deviceRGB,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        return context.makeImage()
    }
}
