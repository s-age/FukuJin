import Foundation

/// How a captured frame is resolved back to pixels in the infrastructure image store.
///
/// The two modes are mutually exclusive and carry exactly the identity each needs — encoding the
/// invariant in the type instead of a bare `UUID?` whose `nil`-means-streaming meaning lived only in
/// a convention comment.
enum CaptureResolution: Equatable, Sendable {
    /// Streaming frames are keyed by `windowID`; the store keeps only the latest frame per window,
    /// so no per-frame token exists.
    case streaming
    /// One-shot snapshots are keyed by `snapshotID`, a per-snapshot token with a TTL in the store.
    case oneShot(snapshotID: UUID)
}

/// A handle to a captured frame held by the infrastructure image store — not the pixels themselves.
struct CapturedImageRef: Equatable, Sendable {
    let resolution: CaptureResolution
    let windowID: UInt32
    let bounds: BoundingBox
}
