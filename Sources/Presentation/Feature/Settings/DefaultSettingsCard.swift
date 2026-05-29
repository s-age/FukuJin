import SwiftUI

struct DefaultSettingsCard: View {
    let viewModel: SettingsViewModel

    var body: some View {
        SettingsSliderPair(
            alpha: SettingsSliderRow(
                title: "Alpha",
                initialValue: viewModel.defaultConfig.opacity,
                range: 0.1...1.0,
                roundToInt: false,
                onChange: { [viewModel] value in viewModel.updateDefaultOpacity(value) }
            ),
            fps: SettingsSliderRow(
                title: "FPS",
                initialValue: viewModel.defaultConfig.fps,
                range: 1...60,
                roundToInt: true,
                onChange: { [viewModel] value in viewModel.updateDefaultFPS(value) }
            )
        )
        .settingsCard(.defaultSettings)
    }
}
