import Foundation
import os
@testable import FukuJin

final class OverlayDomainServiceMock: OverlayDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var activateCallCount = 0
    private(set) var lastActivateWindowID: UInt32?
    private(set) var syncCallCount = 0
    private(set) var lastSyncActivationPID: Int32?

    var stubbedPlan: OverlayPlan = .empty

    func activate(windowID: UInt32) -> OverlayPlan {
        lock.withLock { _ in
            activateCallCount += 1
            lastActivateWindowID = windowID
        }
        return stubbedPlan
    }

    func sync(activationPID: Int32?) -> OverlayPlan {
        lock.withLock { _ in
            syncCallCount += 1
            lastSyncActivationPID = activationPID
        }
        return stubbedPlan
    }
}
