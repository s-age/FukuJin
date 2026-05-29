/// Declarative desired overlay state derived from `(PinnedWindowList, WindowFocusState)`.
///
/// Carries no removal semantics: every pinned window always has an overlay; only ordering and
/// capture-activeness change. The active pin's overlay is ordered below its own real window
/// (so the real window shows) rather than destroyed — destruction happens only on unpin.
struct OverlayPlan: Equatable, Sendable {
    /// The active pin's real window (its CGWindowID); overlays are CGS-ordered below it.
    /// `nil` means no pinned window is frontmost, so every overlay floats.
    let anchorWindowID: UInt32?
    /// Every pinned window's overlay in z-order (pin order; index 0 is topmost within its band).
    let placements: [OverlayPlacement]

    static let empty = OverlayPlan(anchorWindowID: nil, placements: [])
}
