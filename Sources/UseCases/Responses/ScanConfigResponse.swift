struct ScanConfigResponse: Equatable, Sendable {
    let searchText: String
    let actions: [TextWatchActionResponse]
    let isScanning: Bool

    init(from entity: ScanConfig) {
        self.searchText = entity.searchText
        self.actions = entity.actions.map { TextWatchActionResponse(from: $0) }
        self.isScanning = entity.isScanning
    }

    var isCapturing: Bool {
        isScanning && !searchText.isEmpty && !actions.isEmpty
    }
}

enum TextWatchActionResponse: Equatable, Sendable {
    case notification
    case activateWindow
    case command(String)

    init(from entity: TextWatchAction) {
        switch entity {
        case .notification: self = .notification
        case .activateWindow: self = .activateWindow
        case .command(let cmd): self = .command(cmd.raw)
        }
    }
}
