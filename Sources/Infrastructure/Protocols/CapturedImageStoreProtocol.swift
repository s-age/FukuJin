import CoreGraphics
import Foundation

protocol CapturedImageStoreProtocol: Sendable {
    /// One-shot snapshot storage. Returns a new UUID for the stored image.
    /// Entries are evicted lazily after the store's TTL elapses.
    func store(_ image: CGImage) -> UUID

    /// Resolves a one-shot snapshot by its token.
    func resolve(_ id: UUID) -> CGImage?

    /// Streaming storage. Replaces the previous frame for the given windowID.
    func storeLatest(_ image: CGImage, windowID: UInt32)

    /// Resolves the latest streaming frame for the given windowID. O(1) dictionary lookup —
    /// always returns the most recent frame, immune to the per-frame replacement race.
    func resolveLatest(windowID: UInt32) -> CGImage?

    /// Clears the streaming entry for the given windowID. Call when capture stops.
    func clearLatest(windowID: UInt32)
}
