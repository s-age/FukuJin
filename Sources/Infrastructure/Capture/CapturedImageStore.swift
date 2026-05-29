import CoreGraphics
import Foundation
import Synchronization

final class CapturedImageStore: CapturedImageStoreProtocol, Sendable {
    private struct OneShotEntry: Sendable {
        let image: CGImage
        let storedAt: Date
    }

    private let oneShot: Mutex<[UUID: OneShotEntry]> = Mutex([:])
    private let latest: Mutex<[UInt32: CGImage]> = Mutex([:])
    private let ttl: TimeInterval

    init(ttl: TimeInterval = 30) {
        self.ttl = ttl
    }

    func store(_ image: CGImage) -> UUID {
        let id = UUID()
        let now = Date()
        let cutoff = now.addingTimeInterval(-ttl)
        oneShot.withLock { dict in
            dict = dict.filter { $0.value.storedAt >= cutoff }
            dict[id] = OneShotEntry(image: image, storedAt: now)
        }
        return id
    }

    func resolve(_ id: UUID) -> CGImage? {
        oneShot.withLock { $0[id]?.image }
    }

    func storeLatest(_ image: CGImage, windowID: UInt32) {
        latest.withLock { $0[windowID] = image }
    }

    func resolveLatest(windowID: UInt32) -> CGImage? {
        latest.withLock { $0[windowID] }
    }

    func clearLatest(windowID: UInt32) {
        latest.withLock { _ = $0.removeValue(forKey: windowID) }
    }
}
