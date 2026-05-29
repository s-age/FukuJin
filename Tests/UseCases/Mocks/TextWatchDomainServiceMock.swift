import Foundation
import os
@testable import FukuJin

final class TextWatchDomainServiceMock: TextWatchDomainServiceProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var scanAndMatchCallCount = 0
    private(set) var lastScanImage: CapturedImageRef?
    var stubbedScanResult: TextScanResult = TextScanResult(matched: false, matchedBoundingBoxes: [])
    var scanAndMatchError: Error?

    private(set) var executeActionsCallCount = 0
    private(set) var lastActions: [TextWatchAction]?
    private(set) var lastWindowID: UInt32?
    private(set) var lastPID: Int32?
    var stubbedEvents: [TextWatchActionEvent] = []

    func scanAndMatch(image: CapturedImageRef, config: ScanConfig) async throws -> TextScanResult {
        lock.withLock { _ in
            scanAndMatchCallCount += 1
            lastScanImage = image
        }
        if let error = scanAndMatchError { throw error }
        return stubbedScanResult
    }

    func executeActions(
        _ actions: [TextWatchAction],
        windowID: UInt32,
        pid: Int32
    ) async -> [TextWatchActionEvent] {
        lock.withLock { _ in
            executeActionsCallCount += 1
            lastActions = actions
            lastWindowID = windowID
            lastPID = pid
        }
        return stubbedEvents
    }
}
