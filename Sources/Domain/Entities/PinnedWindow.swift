import Foundation

struct PinnedWindow: Identifiable, Equatable, Sendable {
    var id: UInt32 { window.id }
    let window: WindowInfo
    var opacity: Double
    var fps: Double
    var scan: ScanConfig

    static func create(window: WindowInfo, seed: OverlayConfig) -> PinnedWindow {
        PinnedWindow(window: window, opacity: seed.opacity, fps: seed.fps, scan: .default)
    }

    func applyingOpacity(_ value: Double) -> PinnedWindow {
        var copy = self
        copy.opacity = Opacity.clamped(value)
        return copy
    }

    func applyingFPS(_ value: Double) -> PinnedWindow {
        var copy = self
        copy.fps = FPS.clamped(value)
        return copy
    }
}
