import CoreGraphics
import Foundation
import os
@testable import FukuJin

final class CapturedImageResolverMock: CapturedImageResolverProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var resolveCallCount = 0
    private(set) var resolvedWindowIDs: [UInt32] = []
    var stubbedResolveResult: CGImage?

    func resolve(_ image: CapturedImageRefResponse) -> CGImage? {
        lock.withLock { _ in
            resolveCallCount += 1
            resolvedWindowIDs.append(image.windowID)
        }
        return stubbedResolveResult
    }
}
