import Foundation
import os
@testable import FukuJin

final class AppIconDomainServiceMock: AppIconDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var appIconCallCount = 0
    private(set) var lastBundleIdentifier: String?
    private(set) var lastLocalizedName: String?
    var stubbedAppIconData: Data?

    func appIcon(bundleIdentifier: String?, localizedName: String?) -> Data? {
        lock.withLock { _ in
            appIconCallCount += 1
            lastBundleIdentifier = bundleIdentifier
            lastLocalizedName = localizedName
        }
        return stubbedAppIconData
    }
}
