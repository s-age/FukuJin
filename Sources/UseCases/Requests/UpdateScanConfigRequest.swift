struct UpdateScanConfigRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let searchText: String?
    let actions: [TextWatchActionDTO]?
    let isScanning: Bool?

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        if let searchText, searchText.count > 256 {
            throw ValidationError.searchTextTooLong
        }
        if let actions {
            guard actions.count <= 16 else {
                throw ValidationError.tooManyActions
            }
            for action in actions {
                try action.validate()
            }
        }
    }
}

enum TextWatchActionDTO: Equatable, Sendable {
    case notification
    case activateWindow
    case command(String)

    var toDomain: TextWatchAction {
        get throws {
            switch self {
            case .notification: .notification
            case .activateWindow: .activateWindow
            case .command(let cmd): .command(try WatchCommand(cmd))
            }
        }
    }

    func validate() throws {
        guard case .command(let raw) = self else { return }
        _ = try WatchCommand(raw)
    }
}
