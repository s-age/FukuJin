struct ExecuteTextWatchActionResponse: Sendable, Equatable {
    let events: [TextWatchActionEventResponse]

    init(events: [TextWatchActionEventResponse]) {
        self.events = events
    }

    init(from domainEvents: [TextWatchActionEvent]) {
        self.events = domainEvents.map(TextWatchActionEventResponse.init(from:))
    }
}

enum TextWatchActionEventResponse: Sendable, Equatable {
    case notificationRequested
    case windowActivated
    case commandSucceeded
    case commandFailed(TextWatchCommandFailureResponse)

    init(from event: TextWatchActionEvent) {
        switch event {
        case .notificationRequested:
            self = .notificationRequested
        case .windowActivated:
            self = .windowActivated
        case .commandSucceeded:
            self = .commandSucceeded
        case .commandFailed(let failure):
            self = .commandFailed(TextWatchCommandFailureResponse(from: failure))
        }
    }
}

enum TextWatchCommandFailureResponse: Sendable, Equatable {
    case exitedWithNonZeroStatus(status: String)
    case executionFailed

    init(from failure: TextWatchCommandFailure) {
        switch failure {
        case .exitedWithNonZeroStatus(let status):
            self = .exitedWithNonZeroStatus(status: status)
        case .executionFailed:
            self = .executionFailed
        }
    }
}
