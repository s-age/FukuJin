import Foundation
import os
@testable import FukuJin

final class PinDomainServiceMock: PinDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var pinCallCount = 0
    private(set) var unpinCallCount = 0
    private(set) var unpinAllCallCount = 0
    private(set) var mutateWindowCallCount = 0
    private(set) var currentStateCallCount = 0
    private(set) var pruneCallCount = 0
    private(set) var defaultConfigCallCount = 0
    private(set) var updateDefaultConfigCallCount = 0
    private(set) var reorderCallCount = 0
    private(set) var lastReorderArg: [UInt32]?

    var stubbedState: PinnedWindowList = .empty
    var stubbedDefaultConfig: OverlayConfig = .default

    func pin(_ window: WindowInfo, config: OverlayConfig) -> PinnedWindowList {
        lock.withLock { _ in pinCallCount += 1 }
        return stubbedState
    }

    func unpin(_ windowID: UInt32) -> PinnedWindowList {
        lock.withLock { _ in unpinCallCount += 1 }
        return stubbedState
    }

    func unpinAll() -> PinnedWindowList {
        lock.withLock { _ in unpinAllCallCount += 1 }
        return stubbedState
    }

    func mutateWindow(
        windowID: UInt32,
        transform: @Sendable (PinnedWindow) throws -> PinnedWindow
    ) throws -> PinnedWindowList {
        lock.withLock { _ in mutateWindowCallCount += 1 }
        let next = try stubbedState.mutatingWindow(windowID, transform: transform)
        lock.withLock { _ in stubbedState = next }
        return next
    }

    func currentState() -> PinnedWindowList {
        lock.withLock { _ in currentStateCallCount += 1 }
        return stubbedState
    }

    func prune(keeping activeIDs: Set<UInt32>) -> PinnedWindowList {
        lock.withLock { _ in pruneCallCount += 1 }
        return stubbedState
    }

    func defaultConfig() -> OverlayConfig {
        lock.withLock { _ in defaultConfigCallCount += 1 }
        return stubbedDefaultConfig
    }

    func updateDefaultConfig(_ config: OverlayConfig) -> OverlayConfig {
        lock.withLock { _ in updateDefaultConfigCallCount += 1 }
        return config
    }

    func reorder(_ newOrder: [UInt32]) -> PinnedWindowList {
        lock.withLock { _ in
            reorderCallCount += 1
            lastReorderArg = newOrder
        }
        return stubbedState
    }
}
