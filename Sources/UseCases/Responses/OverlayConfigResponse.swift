struct OverlayConfigResponse: Equatable, Sendable {
    let opacity: Double
    let fps: Double

    init(opacity: Double, fps: Double) {
        self.opacity = opacity
        self.fps = fps
    }

    init(from entity: OverlayConfig) {
        self.opacity = entity.opacity
        self.fps = entity.fps
    }
}
