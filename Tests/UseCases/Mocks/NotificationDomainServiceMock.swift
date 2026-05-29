import Foundation
import os
@testable import FukuJin

final class NotificationDomainServiceMock: NotificationDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var sendCallCount = 0
    private(set) var lastTitle: String?
    private(set) var lastBody: String?
    var sendError: Error?

    func send(title: String, body: String) async throws {
        lock.withLock { _ in
            sendCallCount += 1
            lastTitle = title
            lastBody = body
        }
        if let error = sendError { throw error }
    }
}
