import Foundation
import os
@testable import FukuJin

final class ExecuteTextWatchActionUseCaseMock: AsyncUseCase, @unchecked Sendable {
    typealias Request = ExecuteTextWatchActionRequest
    typealias Response = ExecuteTextWatchActionResponse

    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var executeCallCount = 0
    private(set) var lastRequest: ExecuteTextWatchActionRequest?
    var stubbedResponse: ExecuteTextWatchActionResponse = ExecuteTextWatchActionResponse(events: [])
    var executeError: Error?

    func execute(_ request: ExecuteTextWatchActionRequest) async throws -> ExecuteTextWatchActionResponse {
        lock.withLock { _ in
            executeCallCount += 1
            lastRequest = request
        }
        if let error = executeError { throw error }
        return stubbedResponse
    }
}
