import CoreGraphics
import Foundation

final class CGImageCapturedImageResolver: CapturedImageResolverProtocol, Sendable {
    private let resolveFrame: @Sendable (UInt32) -> CGImage?

    init(resolveFrame: @escaping @Sendable (UInt32) -> CGImage?) {
        self.resolveFrame = resolveFrame
    }

    func resolve(_ image: CapturedImageRefResponse) -> CGImage? {
        resolveFrame(image.windowID)
    }
}
