/// Presentation spec for one overlay (a pure value — no CGImage, no NSWindow.Level).
struct OverlayPlacement: Equatable, Sendable {
    let windowID: UInt32
    let opacity: Double
    let fps: Double
    /// `false` when this overlay is fully occluded by its own real window (the active pin):
    /// Presentation pauses its capture and orders it below its real window (z-order inversion).
    let isCaptureActive: Bool
}
