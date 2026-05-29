import Foundation
import os
@testable import FukuJin

final class NotificationRepositoryMock: NotificationRepositoryProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var sendNotificationCallCount = 0
    private(set) var lastTitle: String?
    private(set) var lastBody: String?
    var sendNotificationError: Error?

    private(set) var requestAuthorizationCallCount = 0
    var requestAuthorizationError: Error?

    func sendNotification(title: String, body: String) async throws {
        lock.withLock { _ in
            sendNotificationCallCount += 1
            lastTitle = title
            lastBody = body
        }
        if let error = sendNotificationError { throw error }
    }

    func requestAuthorization() async throws {
        lock.withLock { _ in
            requestAuthorizationCallCount += 1
        }
        if let error = requestAuthorizationError { throw error }
    }
}
