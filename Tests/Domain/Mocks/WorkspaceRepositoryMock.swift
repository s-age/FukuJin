import Foundation
import os
@testable import FukuJin

final class WorkspaceRepositoryMock: WorkspaceRepositoryProtocol, AppIconRepositoryProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var appIconCallCount = 0
    private(set) var lastBundleIdentifier: String?
    private(set) var lastLocalizedName: String?
    var stubbedAppIconData: Data?

    func observeAppActivation() -> AsyncStream<Int32> { AsyncStream { $0.finish() } }

    func frontmostApplicationPID() -> Int32? { nil }

    func activateApp(pid: Int32) {}

    func appIcon(for bundleIdentifier: String?, localizedName: String?) -> Data? {
        lock.withLock { _ in
            appIconCallCount += 1
            lastBundleIdentifier = bundleIdentifier
            lastLocalizedName = localizedName
        }
        return stubbedAppIconData
    }
}
