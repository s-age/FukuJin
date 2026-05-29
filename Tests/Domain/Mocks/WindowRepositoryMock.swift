import Foundation
import os
@testable import FukuJin

final class WindowRepositoryMock: WindowRepositoryProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var listVisibleWindowsCallCount = 0
    var stubbedWindows: [WindowInfo] = []

    func listVisibleWindows() -> [WindowInfo] {
        lock.withLock { _ in listVisibleWindowsCallCount += 1 }
        return stubbedWindows
    }
}
