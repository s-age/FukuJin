import Foundation

struct OverlayConfig: Equatable, Sendable, Codable {
    let opacity: Double
    let fps: Double

    private init(opacity: Double, fps: Double) {
        self.opacity = opacity
        self.fps = fps
    }

    static let `default` = OverlayConfig(opacity: 0.5, fps: 1.0)

    static func create(opacity: Double, fps: Double) -> OverlayConfig {
        OverlayConfig(
            opacity: Opacity.clamped(opacity),
            fps: FPS.clamped(fps)
        )
    }

    func applying(opacity: Double) -> OverlayConfig {
        OverlayConfig.create(opacity: opacity, fps: fps)
    }

    func applying(fps: Double) -> OverlayConfig {
        OverlayConfig.create(opacity: opacity, fps: fps)
    }
}
