import SwiftUI

struct SettingsSliderRow: View {
    let title: String
    let initialValue: Double
    let range: ClosedRange<Double>
    let roundToInt: Bool
    let onChange: (Double) -> Void

    @State private var value: Double

    init(
        title: String,
        initialValue: Double,
        range: ClosedRange<Double>,
        roundToInt: Bool,
        onChange: @escaping (Double) -> Void
    ) {
        self.title = title
        self.initialValue = initialValue
        self.range = range
        self.roundToInt = roundToInt
        self.onChange = onChange
        self._value = State(initialValue: initialValue)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
            Text(formatValue(value, roundToInt: roundToInt))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 28, alignment: .leading)
            Slider(value: $value, in: range)
                .onChange(of: value) { _, newValue in
                    let snapped = roundToInt ? newValue.rounded() : newValue
                    if roundToInt && snapped != newValue {
                        value = snapped
                    }
                    onChange(snapped)
                }
        }
        // Re-seed the local editing buffer when the source value changes externally
        // (e.g. reset-to-defaults). `State(initialValue:)` only applies at first
        // construction, so a stable view identity would otherwise keep a stale value.
        // The equality guard prevents the slider's own writes from re-triggering.
        .onChange(of: initialValue) { _, newValue in
            if newValue != value { value = newValue }
        }
    }
}

struct SettingsSliderPair: View {
    let alpha: SettingsSliderRow
    let fps: SettingsSliderRow

    var body: some View {
        HStack(spacing: 20) {
            alpha.frame(maxWidth: .infinity)
            fps.frame(maxWidth: .infinity)
        }
    }
}
