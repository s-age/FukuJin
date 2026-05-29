import CoreGraphics
import Foundation
import os
@testable import FukuJin

final class CapturedImageStoreMock: CapturedImageStoreProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var storeCallCount = 0
    private(set) var resolveCallCount = 0
    private(set) var storeLatestCallCount = 0
    private(set) var resolveLatestCallCount = 0
    private(set) var clearLatestCallCount = 0

    private(set) var resolvedIDs: [UUID] = []
    private(set) var resolvedWindowIDs: [UInt32] = []

    var stubbedResolveResult: CGImage?

    func store(_ image: CGImage) -> UUID {
        lock.withLock { _ in storeCallCount += 1 }
        return UUID()
    }

    func resolve(_ id: UUID) -> CGImage? {
        lock.withLock { _ in
            resolveCallCount += 1
            resolvedIDs.append(id)
        }
        return stubbedResolveResult
    }

    func storeLatest(_ image: CGImage, windowID: UInt32) {
        lock.withLock { _ in storeLatestCallCount += 1 }
    }

    func resolveLatest(windowID: UInt32) -> CGImage? {
        lock.withLock { _ in
            resolveLatestCallCount += 1
            resolvedWindowIDs.append(windowID)
        }
        return stubbedResolveResult
    }

    func clearLatest(windowID: UInt32) {
        lock.withLock { _ in clearLatestCallCount += 1 }
    }
}
