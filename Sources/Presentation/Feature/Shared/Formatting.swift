import Foundation

func formatValue(_ value: Double, roundToInt: Bool) -> String {
    if roundToInt {
        return String(Int(value.rounded()))
    }
    return String(format: "%.1f", value)
}
