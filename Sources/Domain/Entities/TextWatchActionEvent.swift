import Foundation

enum TextWatchActionEvent: Equatable, Sendable {
    case notificationRequested
    case windowActivated
    case commandSucceeded
    case commandFailed(TextWatchCommandFailure)
}
