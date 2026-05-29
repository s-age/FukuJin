import SwiftUI

struct PinnedWindowRow: View {
    let entry: PinnedWindowResponse
    let isScanning: Bool
    let viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TitleRow(
                title: entry.displayTitle,
                iconImage: viewModel.appIcon(localizedName: entry.ownerName)
            )
            SettingsSliderPair(
                alpha: SettingsSliderRow(
                    title: "Alpha",
                    initialValue: entry.opacity,
                    range: 0.1...1.0,
                    roundToInt: false,
                    onChange: { [viewModel, windowID = entry.windowID] value in
                        viewModel.updateOpacity(windowID: windowID, value)
                    }
                ),
                fps: SettingsSliderRow(
                    title: "FPS",
                    initialValue: entry.fps,
                    range: 1...60,
                    roundToInt: true,
                    onChange: { [viewModel, windowID = entry.windowID] value in
                        viewModel.updateFPS(windowID: windowID, value)
                    }
                )
            )
            WatcherSection(entry: entry, isScanning: isScanning, viewModel: viewModel)
        }
        .settingsCard(.pinnedWindow)
    }
}

private struct TitleRow: View {
    let title: String
    let iconImage: Image?

    var body: some View {
        HStack(spacing: 6) {
            AppIcon(image: iconImage, size: 16)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
