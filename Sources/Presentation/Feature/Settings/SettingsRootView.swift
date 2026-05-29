import SwiftUI

struct SettingsRootView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            SectionHeaderRow(
                title: "Default Settings",
                description: "Initial values applied when pinning a new window."
            )
            DefaultSettingsCard(viewModel: viewModel)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 32))

            if viewModel.pinnedWindows.hasPinnedWindows {
                SectionHeaderRow(
                    title: "Pinned Windows",
                    description: "Currently pinned windows. Drag to reorder. "
                        + "Set a search text to get a notification or run a "
                        + "command when the text appears in the captured frame."
                )
                ForEach(viewModel.pinnedWindows.windows, id: \.windowID) { entry in
                    PinnedWindowRow(
                        entry: entry,
                        isScanning: viewModel.isScanning(windowID: entry.windowID),
                        viewModel: viewModel
                    )
                    .padding(.bottom, 8)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 32))
                }
                .onMove { source, destination in
                    var ids = viewModel.pinnedWindows.windows.map(\.windowID)
                    ids.move(fromOffsets: source, toOffset: destination)
                    viewModel.reorderPinnedWindows(ids)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay(alignment: .topTrailing) {
            RecognitionLanguageButton(viewModel: viewModel)
                .padding(.top, 12)
                .padding(.trailing, 20)
        }
        .task {
            viewModel.refreshDefaultConfig()
            viewModel.refreshRecognitionLanguages()
        }
    }
}

private struct SectionHeaderRow: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Text(description)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 4)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 32))
    }
}
