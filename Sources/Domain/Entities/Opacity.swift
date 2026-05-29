import Foundation

/// Single source of the overlay opacity range rule.
///
/// Both `OverlayConfig.create` and `PinnedWindow.applyingOpacity` delegate here
/// so the valid range and clamp behavior live in exactly one place.
enum Opacity {
    static let range: ClosedRange<Double> = 0.1...1.0

    static func clamped(_ value: Double) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
