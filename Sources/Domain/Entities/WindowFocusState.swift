/// Authoritative state for "which pinned window's real window is currently frontmost on screen".
///
/// Owned by the Domain (not re-derived from a laggy OS query each time). Modeled as a sum type so
/// the "no focus" and "focused" cases cannot disagree (a windowID without an ownerPID, or vice
/// versa, is unrepresentable). The `origin` records how the focus was established and governs the
/// lag guard: an explicit (user-clicked) focus has a pending real-window raise that may race
/// `CGWindowList`, so a same-app empty observation is treated as lag; an OS-observed focus has no
/// pending raise, so a fresh empty observation is authoritative.
enum WindowFocusState: Equatable, Sendable {
    case none
    case focused(windowID: UInt32, ownerPID: Int32, origin: Origin)

    /// How the current focus was established.
    enum Origin: Equatable, Sendable {
        /// Set by explicit user intent (`windowFocused`); a real-window raise is pending.
        case explicit
        /// Derived from OS frontmost enumeration (`appActivated`); no pending raise.
        case observed
    }

    /// The pinned window the focus points at, or `nil` when nothing is focused.
    var focusedWindowID: UInt32? {
        switch self {
        case .none: return nil
        case let .focused(windowID, _, _): return windowID
        }
    }
}
