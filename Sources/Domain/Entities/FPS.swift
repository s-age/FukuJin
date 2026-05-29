import Foundation

/// Single source of the overlay frame-rate range rule.
///
/// Both `OverlayConfig.create` and `PinnedWindow.applyingFPS` delegate here so
/// the valid range, integer rounding, and clamp behavior live in one place.
enum FPS {
    static let range: ClosedRange<Double> = 1...60

    static func clamped(_ value: Double) -> Double {
        min(max(value.rounded(), range.lowerBound), range.upperBound)
    }
}
