import Foundation
import os
@testable import FukuJin

final class StubSyncUseCase<Req: UseCaseRequest, Res: Sendable>: SyncUseCase, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())
    private var _callCount = 0
    private var _lastRequest: Req?

    var callCount: Int { lock.withLock { _ in _callCount } }
    var lastRequest: Req? { lock.withLock { _ in _lastRequest } }

    var stubbedResult: Res
    var stubbedError: Error?

    init(stubbedResult: Res) {
        self.stubbedResult = stubbedResult
    }

    func execute(_ request: Req) throws -> Res {
        lock.withLock { _ in
            _callCount += 1
            _lastRequest = request
        }
        if let err = stubbedError { throw err }
        return stubbedResult
    }
}

final class StubAsyncUseCase<Req: UseCaseRequest, Res: Sendable>: AsyncUseCase, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())
    private var _callCount = 0

    var callCount: Int { lock.withLock { _ in _callCount } }

    var stubbedResult: Res
    var stubbedError: Error?

    init(stubbedResult: Res) {
        self.stubbedResult = stubbedResult
    }

    func execute(_ request: Req) async throws -> Res {
        lock.withLock { _ in _callCount += 1 }
        if let err = stubbedError { throw err }
        return stubbedResult
    }
}
