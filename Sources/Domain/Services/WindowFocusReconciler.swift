/// Pure, stateless reconcile rule — the single source of truth for how `WindowFocusState`
/// transitions on each `WindowFocusEvent`. The primary unit-test target.
struct WindowFocusReconciler: Sendable {
    func reconcile(current: WindowFocusState, event: WindowFocusEvent) -> WindowFocusState {
        switch event {
        case let .windowFocused(windowID, ownerPID):
            // Explicit user intent is authoritative; a real-window raise is now pending.
            return .focused(windowID: windowID, ownerPID: ownerPID, origin: .explicit)

        case let .appActivated(pid, observed):
            if let observed {
                return .focused(windowID: observed, ownerPID: pid, origin: .observed)
            }
            // Empty observation. Keep the current focus only when the *same* app re-activates and
            // that focus came from explicit intent — `CGWindowList` may not yet reflect the raise
            // the user just triggered (lag guard), so re-covering the real window would be wrong.
            // A focus that was itself OS-observed has no pending raise to protect, so a fresh empty
            // observation is authoritative and clears it (avoids falsely retaining a stale focus).
            if case let .focused(_, ownerPID, origin) = current, origin == .explicit, ownerPID == pid {
                return current
            }
            return .none

        case let .windowUnpinned(windowID):
            // The window backing the current focus is gone. If it was the focused window, the
            // authority is now stale → clear it. An unrelated window's removal leaves focus intact.
            if current.focusedWindowID == windowID {
                return .none
            }
            return current
        }
    }

    /// Re-validate the focus authority against a fresh pin snapshot. A pin can disappear (unpin /
    /// prune / target lost) without routing an event through here, so the focused window may no
    /// longer exist in the current snapshot. When that happens, collapse the focus by replaying a
    /// `windowUnpinned` transition — keeping *all* focus-state rules in this one pure type rather
    /// than leaking the staleness rule into the orchestrating service. A still-pinned (or absent)
    /// focus is left untouched.
    func reconcileLiveness(current: WindowFocusState, against pinned: PinnedWindowList) -> WindowFocusState {
        guard let id = current.focusedWindowID, !pinned.isPinned(id) else { return current }
        return reconcile(current: current, event: .windowUnpinned(windowID: id))
    }
}
