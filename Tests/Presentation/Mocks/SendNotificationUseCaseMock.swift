import Foundation
import os
@testable import FukuJin

final class SendNotificationUseCaseMock: AsyncUseCase, @unchecked Sendable {
    typealias Request = SendNotificationRequest
    typealias Response = Void

    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var executeCallCount = 0
    private(set) var executedRequests: [SendNotificationRequest] = []
    var executeError: Error?

    func execute(_ request: SendNotificationRequest) async throws {
        lock.withLock { _ in
            executeCallCount += 1
            executedRequests.append(request)
        }
        if let error = executeError { throw error }
    }
}
