import SwiftUI

struct MenuBarRootView: View {
    let viewModel: MenuBarViewModel
    let onShowSettings: @MainActor () -> Void
    let onQuit: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            actionRow(title: "Settings", systemImage: "gearshape") {
                onShowSettings()
            }

            Divider().padding(.vertical, 4)

            if viewModel.pinnedWindows.hasPinnedWindows {
                sectionHeader("Pinned")
                ForEach(viewModel.pinnedWindows.windows, id: \.windowID) { entry in
                    pinnedRow(entry)
                }
                actionRow(title: "Unpin All", systemImage: "pin.slash", alignment: .trailing) {
                    viewModel.unpinAllWindows()
                }
                Divider().padding(.vertical, 4)
            }

            if !unpinnedGroups.isEmpty {
                ForEach(unpinnedGroups, id: \.appName) { group in
                    appGroup(group)
                }
                Divider().padding(.vertical, 4)
            }

            launchAtLoginRow

            Divider().padding(.vertical, 4)

            quitRow
        }
        .padding(.vertical, 6)
        .frame(width: 280)
        .task {
            viewModel.refreshWindows()
            viewModel.pruneStaleWindows()
        }
    }

    // MARK: - Derived data

    private var unpinnedGroups: [WindowGroupResponse] {
        viewModel.windowGroups.compactMap { group in
            let unpinned = group.windows.filter { viewModel.pinnedWindows[$0.id] == nil }
            guard !unpinned.isEmpty else { return nil }
            return WindowGroupResponse(appName: group.appName, windows: unpinned)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
    }

    /// Pinned windows render as a flat list in `pinnedWindows.windowIDs` — the same source the
    /// Settings modal reorders — so the menu and Settings always agree on stacking. App grouping
    /// is dropped here precisely because pin order can interleave windows from different apps.
    @ViewBuilder
    private func pinnedRow(_ entry: PinnedWindowResponse) -> some View {
        Button {
            viewModel.unpin(windowID: entry.windowID)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "checkmark").frame(width: 12)
                AppIcon(image: viewModel.appIcon(localizedName: entry.ownerName), size: 14)
                Text(entry.displayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func appGroup(_ group: WindowGroupResponse) -> some View {
        appHeader(group.appName)
        ForEach(group.windows, id: \.id) { window in
            windowRow(window)
        }
    }

    @ViewBuilder
    private func appHeader(_ appName: String) -> some View {
        HStack(spacing: 6) {
            AppIcon(image: viewModel.appIcon(localizedName: appName), size: 14)
            Text(appName).font(.system(size: 12, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private func windowRow(_ window: WindowInfoResponse) -> some View {
        Button {
            viewModel.togglePin(window)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "")
                    .frame(width: 12)
                Text(window.displayName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var quitRow: some View {
        HStack(spacing: 6) {
            Spacer()
            Button {
                onQuit()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Quit")
                }
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var launchAtLoginRow: some View {
        HStack {
            Text("Launch at Login")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.launchAtLogin },
                set: { viewModel.setLaunchAtLogin($0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func actionRow(
        title: String,
        systemImage: String,
        alignment: HorizontalAlignment = .leading,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if alignment == .trailing { Spacer() }
                Image(systemName: systemImage).frame(width: 14)
                Text(title)
                if alignment == .leading { Spacer() }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
