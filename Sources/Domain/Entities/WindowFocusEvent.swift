/// Inputs that transition `WindowFocusState`. Unifies explicit user intent and OS observation.
enum WindowFocusEvent: Equatable, Sendable {
    /// The user explicitly brought a pinned window's real window forward (clicked its overlay).
    case windowFocused(windowID: UInt32, ownerPID: Int32)
    /// An app became active. `observedFrontmostPinnedWindowID` is the topmost *pinned* window
    /// owned by that app per OS enumeration — may lag reality, or be `nil` if none.
    case appActivated(pid: Int32, observedFrontmostPinnedWindowID: UInt32?)
    /// The pinned window backing the current focus disappeared (unpinned / pruned / target lost),
    /// so a focus authority pointing at it is now stale. Lets the authority — not the pure plan
    /// policy — absorb the staleness.
    case windowUnpinned(windowID: UInt32)
}
