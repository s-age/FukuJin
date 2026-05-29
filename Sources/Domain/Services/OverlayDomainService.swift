import Synchronization

/// Single Domain entry for overlay behavior. Owns the authoritative `WindowFocusState` and
/// composes pin state, window raising, OS observation, and the pure policy/reconciler. Modeled
/// after `TextWatchDomainService`, which likewise composes several services.
final class OverlayDomainService: OverlayDomainServiceProtocol, Sendable {
    private let pinService: any PinDomainServiceProtocol
    private let actionService: any WindowActionDomainServiceProtocol
    private let discoveryService: any WindowDiscoveryDomainServiceProtocol
    private let policy: any OverlayPolicyDomainServiceProtocol
    private let reconciler: WindowFocusReconciler
    private let focus: Mutex<WindowFocusState> = Mutex(.none)

    init(
        pinService: any PinDomainServiceProtocol,
        actionService: any WindowActionDomainServiceProtocol,
        discoveryService: any WindowDiscoveryDomainServiceProtocol,
        policy: any OverlayPolicyDomainServiceProtocol,
        reconciler: WindowFocusReconciler = WindowFocusReconciler()
    ) {
        self.pinService = pinService
        self.actionService = actionService
        self.discoveryService = discoveryService
        self.policy = policy
        self.reconciler = reconciler
    }

    func activate(windowID: UInt32) -> OverlayPlan {
        let pinned = pinService.currentState()
        let resolvedPID = pinned[windowID]?.window.ownerPID
        // One path: build the focus event (a live target focuses it, a vanished one is reported as
        // unpinned), reconcile, and derive the plan as a single atomic step over the authority so
        // the snapshot, the transition, and the plan agree. The real-window raise is a side effect
        // emitted only after the authoritative state is committed (TOCTOU).
        let event: WindowFocusEvent = resolvedPID
            .map { .windowFocused(windowID: windowID, ownerPID: $0) }
            ?? .windowUnpinned(windowID: windowID)
        let plan = focus.withLock { state -> OverlayPlan in
            state = apply(event, to: state, livenessAgainst: pinned)
            return policy.plan(pinnedWindows: pinned, focus: state)
        }
        if let pid = resolvedPID {
            actionService.raiseWindow(windowID: windowID, pid: pid)
        }
        return plan
    }

    func sync(activationPID: Int32?) -> OverlayPlan {
        let pinned = pinService.currentState()
        // Resolve the OS observation outside the lock (it is a potentially slow query), then commit
        // the transition and plan atomically.
        let observedPinned = activationPID.flatMap { pid in
            discoveryService.frontmostWindowID(ownedBy: pid).flatMap { pinned.isPinned($0) ? $0 : nil }
        }
        return focus.withLock { state -> OverlayPlan in
            if let pid = activationPID {
                let event = WindowFocusEvent.appActivated(pid: pid, observedFrontmostPinnedWindowID: observedPinned)
                state = apply(event, to: state, livenessAgainst: pinned)
            } else {
                // Pin-state change (no activation): no new OS signal, but the focused window may
                // have just been unpinned/pruned — re-validate against the fresh snapshot.
                state = reconciler.reconcileLiveness(current: state, against: pinned)
            }
            return policy.plan(pinnedWindows: pinned, focus: state)
        }
    }

    /// Apply a focus event, then re-validate the result against the pin snapshot. Both the
    /// transition rule and the liveness rule live in the pure reconciler; this service only
    /// orchestrates the order in which they run.
    private func apply(
        _ event: WindowFocusEvent, to state: WindowFocusState, livenessAgainst pinned: PinnedWindowList
    ) -> WindowFocusState {
        let next = reconciler.reconcile(current: state, event: event)
        return reconciler.reconcileLiveness(current: next, against: pinned)
    }
}
