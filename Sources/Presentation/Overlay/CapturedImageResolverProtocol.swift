import CoreGraphics
import Foundation

protocol CapturedImageResolverProtocol: Sendable {
    func resolve(_ image: CapturedImageRefResponse) -> CGImage?
}
