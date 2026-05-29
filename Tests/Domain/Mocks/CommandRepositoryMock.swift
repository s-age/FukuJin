import Foundation
import os
@testable import FukuJin

final class CommandRepositoryMock: CommandRepositoryProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var executeCallCount = 0
    private(set) var lastCommand: String?
    var executeError: Error?

    func execute(_ command: WatchCommand) async throws {
        lock.withLock { _ in
            executeCallCount += 1
            lastCommand = command.raw
        }
        if let error = executeError { throw error }
    }
}
