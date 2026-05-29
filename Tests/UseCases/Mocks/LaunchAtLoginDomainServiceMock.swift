import Foundation
import os
@testable import FukuJin

final class LaunchAtLoginDomainServiceMock: LaunchAtLoginDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var isEnabledCallCount = 0
    private(set) var setEnabledCallCount = 0
    private(set) var lastSetEnabledArg: Bool?

    /// The value `isEnabled()` reports — kept independent of `setEnabled` so tests
    /// can simulate the OS refusing or silently dropping a write.
    var stubbedIsEnabled = false
    var setEnabledError: (any Error)?

    func isEnabled() -> Bool {
        lock.withLock { _ in isEnabledCallCount += 1 }
        return stubbedIsEnabled
    }

    func setEnabled(_ enabled: Bool) throws {
        try lock.withLock { _ in
            setEnabledCallCount += 1
            lastSetEnabledArg = enabled
            if let setEnabledError { throw setEnabledError }
        }
    }
}
