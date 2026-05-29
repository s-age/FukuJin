import Foundation
import os
@testable import FukuJin

final class WindowActionDomainServiceMock: WindowActionDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var raiseWindowCallCount = 0
    private(set) var lastRaiseWindowID: UInt32?
    private(set) var lastRaisePID: Int32?

    private(set) var activateAppCallCount = 0
    private(set) var requestAccessibilityPermissionCallCount = 0
    private(set) var orderWindowCallCount = 0
    private(set) var observeAppActivationCallCount = 0

    func raiseWindow(windowID: UInt32, pid: Int32) {
        lock.withLock { _ in
            raiseWindowCallCount += 1
            lastRaiseWindowID = windowID
            lastRaisePID = pid
        }
    }

    func activateApp(pid: Int32) {
        lock.withLock { _ in activateAppCallCount += 1 }
    }

    func requestAccessibilityPermission() {
        lock.withLock { _ in requestAccessibilityPermissionCallCount += 1 }
    }

    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32) {
        lock.withLock { _ in orderWindowCallCount += 1 }
    }

    func observeAppActivation() -> AsyncStream<Int32> {
        lock.withLock { _ in observeAppActivationCallCount += 1 }
        return AsyncStream { $0.finish() }
    }
}
