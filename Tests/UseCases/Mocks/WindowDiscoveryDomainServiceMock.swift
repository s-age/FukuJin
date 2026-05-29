import Foundation
import os
@testable import FukuJin

final class WindowDiscoveryDomainServiceMock: WindowDiscoveryDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var frontmostWindowIDCallCount = 0
    private(set) var lastFrontmostOwnerPID: Int32?
    var stubbedFrontmostWindowID: UInt32?
    var stubbedWindows: [WindowInfo] = []
    var stubbedGroups: [WindowGroup] = []

    func discoverWindows() -> [WindowInfo] { stubbedWindows }

    func groupByApp(_ windows: [WindowInfo]) -> [WindowGroup] { stubbedGroups }

    func frontmostWindowID(ownedBy pid: Int32) -> UInt32? {
        lock.withLock { _ in
            frontmostWindowIDCallCount += 1
            lastFrontmostOwnerPID = pid
        }
        return stubbedFrontmostWindowID
    }
}
