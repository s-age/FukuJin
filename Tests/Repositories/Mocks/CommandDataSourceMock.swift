import Foundation
import os
@testable import FukuJin

final class CommandDataSourceMock: CommandDataSourceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var executeCallCount = 0
    private(set) var lastExecutedCommand: String?
    var executeError: Error?

    func execute(_ command: String) async throws {
        lock.withLock { _ in
            executeCallCount += 1
            lastExecutedCommand = command
        }
        if let error = executeError { throw error }
    }
}
