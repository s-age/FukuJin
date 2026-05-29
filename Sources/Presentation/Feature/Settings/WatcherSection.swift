import SwiftUI

struct WatcherSection: View {
    let entry: PinnedWindowResponse
    let isScanning: Bool
    let viewModel: SettingsViewModel

    @State private var searchText: String
    @State private var selectedAction: ActionKind
    @State private var commandText: String
    @State private var searchDebounce: Task<Void, Never>?

    init(entry: PinnedWindowResponse, isScanning: Bool, viewModel: SettingsViewModel) {
        self.entry = entry
        self.isScanning = isScanning
        self.viewModel = viewModel
        let firstAction = entry.scan.actions.first
        self._searchText = State(initialValue: entry.scan.searchText)
        self._selectedAction = State(initialValue: ActionKind(from: firstAction))
        if case .command(let cmd) = firstAction {
            self._commandText = State(initialValue: cmd)
        } else {
            self._commandText = State(initialValue: "")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                captureToggleButton
                TextField("Search text...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    // Debounce persistence: each keystroke would otherwise reassign the global
                    // `pinnedWindows` and reload the whole List (NSTableView-backed), which jostles
                    // the focused field and lags typing. The local @State drives the visible text
                    // immediately; the watcher (5s poll) only needs the value after a brief pause.
                    .onChange(of: searchText) { _, newValue in
                        searchDebounce?.cancel()
                        let windowID = entry.windowID
                        searchDebounce = Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(350))
                            guard !Task.isCancelled else { return }
                            viewModel.updateTextWatchSearch(windowID: windowID, searchText: newValue)
                        }
                    }
                Picker("", selection: $selectedAction) {
                    Text("Notification").tag(ActionKind.notification)
                    Text("Activate Window").tag(ActionKind.activateWindow)
                    Text("Run Command").tag(ActionKind.command)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .fixedSize()
                .onChange(of: selectedAction) { _, newValue in
                    viewModel.updateTextWatchAction(
                        windowID: entry.windowID,
                        action: newValue.dto(commandText: commandText)
                    )
                }
            }

            if selectedAction == .command {
                CommandTextEditor(
                    initial: commandText,
                    placeholder: "e.g. say \"text found\" or /path/to/script.sh"
                ) { text in
                    commandText = text
                    viewModel.updateTextWatchAction(windowID: entry.windowID, action: .command(text))
                }
                .frame(height: 64)

                Label(
                    "Commands run through the shell. Only enter input you trust.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .labelStyle(.titleAndIcon)
            }
        }
        // Re-seed the local editing buffers when the underlying pinned window changes
        // externally. `State(initialValue:)` only applies at first construction, so a
        // stable view identity would otherwise strand stale text/action selections.
        // Equality guards stop each field's own onChange writes from echoing back.
        .onChange(of: entry) { _, newEntry in
            let firstAction = newEntry.scan.actions.first
            if newEntry.scan.searchText != searchText { searchText = newEntry.scan.searchText }
            let kind = ActionKind(from: firstAction)
            if kind != selectedAction { selectedAction = kind }
            if case .command(let cmd) = firstAction, cmd != commandText { commandText = cmd }
        }
    }

    private var captureToggleButton: some View {
        Button {
            viewModel.setScanning(windowID: entry.windowID, isScanning: !isScanning)
        } label: {
            Image(systemName: isScanning ? "pause.fill" : "play.fill")
                .font(.system(size: 11))
                .foregroundStyle(.primary)
        }
        .buttonStyle(.borderless)
        .help(isScanning ? "Pause Capture" : "Resume Capture")
    }
}

enum ActionKind: Hashable {
    case notification
    case activateWindow
    case command

    init(from action: TextWatchActionResponse?) {
        switch action {
        case .activateWindow: self = .activateWindow
        case .command: self = .command
        default: self = .notification
        }
    }

    func dto(commandText: String) -> TextWatchActionDTO {
        switch self {
        case .notification: .notification
        case .activateWindow: .activateWindow
        case .command: .command(commandText)
        }
    }
}
