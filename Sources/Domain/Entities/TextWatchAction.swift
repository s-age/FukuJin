import Foundation

enum TextWatchAction: Equatable, Sendable {
    case notification
    case activateWindow
    case command(WatchCommand)
}
