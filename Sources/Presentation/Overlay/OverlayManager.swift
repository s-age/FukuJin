import AppKit

/// Executes an `OverlayPlanResponse` (decided by the Domain) against the overlay `NSWindow`s it
/// owns. Holds no visibility/order *policy* — that lives in the Domain. Responsibilities:
/// create/destroy windows on pin/unpin, apply opacity, pause/resume capture per the plan, and
/// realize the z-order (float, or CGS-below the active pin's real window).
@MainActor
final class OverlayManager {
    private var sessions: [UInt32: OverlaySession] = [:]
    private var pendingCreations: Set<UInt32> = []
    private var currentPlan = OverlayPlanResponse(from: .empty)

    private let captureWindow: CaptureWindowUseCaseProtocol
    private let manageCaptureStream: ManageCaptureStreamUseCaseProtocol
    private let orderWindowBelow: OrderWindowBelowUseCaseProtocol
    private let observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol
    private let resolver: any CapturedImageResolverProtocol
    private let syncOverlaysUseCase: SyncOverlaysUseCaseProtocol
    private let activatePinnedWindowUseCase: ActivatePinnedWindowUseCaseProtocol

    /// Invoked when a capture stream ends because its target window vanished. The owner unpins it.
    var onTargetLost: (@MainActor (UInt32) -> Void)?

    /// Invoked when any overlay is clicked. The owner (App layer) uses it to dismiss the open
    /// `MenuBarExtra` popover: clicking an overlay raises another app via `acceptsFirstMouse`, which
    /// bypasses the popover's outside-click dismissal, so the popover must be closed explicitly.
    var onOverlayClicked: (@MainActor () -> Void)?

    init(
        captureWindow: CaptureWindowUseCaseProtocol,
        manageCaptureStream: ManageCaptureStreamUseCaseProtocol,
        orderWindowBelow: OrderWindowBelowUseCaseProtocol,
        observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol,
        resolver: any CapturedImageResolverProtocol,
        syncOverlays: SyncOverlaysUseCaseProtocol,
        activatePinnedWindow: ActivatePinnedWindowUseCaseProtocol
    ) {
        self.captureWindow = captureWindow
        self.manageCaptureStream = manageCaptureStream
        self.orderWindowBelow = orderWindowBelow
        self.observeCaptureFrames = observeCaptureFrames
        self.resolver = resolver
        self.syncOverlaysUseCase = syncOverlays
        self.activatePinnedWindowUseCase = activatePinnedWindow
    }

    /// Resolve the desired overlay plan from the Domain and apply it. `activationPID` is set when
    /// an app activated; `nil` after a pin-state change (pin/unpin/reorder/opacity/fps).
    func sync(activationPID: Int32?) {
        guard let plan = try? syncOverlaysUseCase.execute(
            SyncOverlaysRequest(activationPID: activationPID)
        ) else { return }
        apply(plan)
    }

    func setHighlights(for windowID: UInt32, boundingBoxes: [BoundingBoxResponse]) {
        sessions[windowID]?.window?.setHighlights(boundingBoxes)
    }

    /// Window IDs with a materialised overlay window. Read-only view for observation/tests.
    var overlayWindowIDs: Set<UInt32> { Set(sessions.compactMap { $0.value.window != nil ? $0.key : nil }) }

    func teardownAll() {
        for session in sessions.values { session.teardown() }
        sessions.removeAll()
    }

    // MARK: - Plan application

    /// Reconcile live overlays to the plan. Windows are created/destroyed only on pin/unpin
    /// (the plan always lists every pinned window); focus changes only reorder + toggle capture.
    func apply(_ plan: OverlayPlanResponse) {
        currentPlan = plan
        let desired = Set(plan.placements.map(\.windowID))

        for id in Set(sessions.keys) where !desired.contains(id) {
            removeOverlay(id: id)
        }

        for placement in plan.placements {
            if let session = sessions[placement.windowID], session.window != nil {
                configure(session: session, placement: placement)
            } else {
                scheduleCreation(of: placement)
            }
        }

        applyOrdering(plan)
    }

    private func configure(session: OverlaySession, placement: OverlayPlacementResponse) {
        session.window?.inactiveOpacity = CGFloat(placement.opacity)
        if session.monitor.fps != placement.fps { session.monitor.updateFPS(placement.fps) }
        applyCaptureState(session: session, isActive: placement.isCaptureActive)
    }

    /// Pause capture for an overlay fully occluded by its own real window (the active pin),
    /// resume it otherwise. Pausing keeps the window alive (no create/destroy churn) but stops the
    /// wasted capture of a hidden surface.
    private func applyCaptureState(session: OverlaySession, isActive: Bool) {
        switch (isActive, session.monitor.state) {
        case (true, .idle):
            Task { await session.monitor.start() }
        case (false, .starting), (false, .monitoring):
            session.monitor.teardown()
        default:
            break
        }
    }

    private func scheduleCreation(of placement: OverlayPlacementResponse) {
        guard !pendingCreations.contains(placement.windowID) else { return }
        pendingCreations.insert(placement.windowID)
        Task { [weak self] in
            await self?.createOverlay(placement)
            guard let self else { return }
            self.pendingCreations.remove(placement.windowID)
            // Re-run ordering once the batch drains so newly materialised windows take their slot.
            if self.pendingCreations.isEmpty { self.applyOrdering(self.currentPlan) }
        }
    }

    // MARK: - Z-order

    private func applyOrdering(_ plan: OverlayPlanResponse) {
        let order = plan.placements.map(\.windowID)
        if let anchor = plan.anchorWindowID {
            // The active pin's own overlay is fully hidden (orderOut), not merely chained below its
            // real window: with capture paused it stops following, so leaving it on-screen-but-below
            // would strand a stale frame at the old spot when the user moves the real window.
            sessions[anchor]?.window?.orderOut(nil)
            applyOrderingBelowRealWindow(order.filter { $0 != anchor }, anchor: anchor)
        } else {
            applyFloatingOrdering(order)
        }
    }

    /// No pinned window is frontmost: every overlay floats, stacked so `order[0]` ends up on top.
    /// Same-level (`.floating`) windows obey call order, so front them back-to-front.
    /// (See nswindow-orderfront-same-level-call-order-wins.)
    private func applyFloatingOrdering(_ order: [UInt32]) {
        for id in order {
            sessions[id]?.window?.level = .floating
        }
        for id in order.reversed() {
            sessions[id]?.window?.orderFront(nil)
        }
    }

    /// A pinned window is frontmost (`anchor` = its real window's CGWindowID). The remaining
    /// overlays (the active pin's own is hidden via orderOut by the caller) are CGS-chained below
    /// it in pin order so none covers the real window. `orderFront` primes each before the
    /// cross-level CGS-below, otherwise the constraint no-ops.
    /// (See cgs-order-window-cross-level-needs-orderfront-priming.)
    private func applyOrderingBelowRealWindow(_ order: [UInt32], anchor: UInt32) {
        var previousCGSID = anchor
        for id in order {
            guard let window = sessions[id]?.window else { continue }
            window.level = .normal
            window.orderFront(nil)
            let overlayCGSID = UInt32(bitPattern: Int32(window.windowNumber))
            try? orderWindowBelow.execute(
                OrderWindowBelowRequest(windowID: overlayCGSID, relativeWindowID: previousCGSID)
            )
            previousCGSID = overlayCGSID
        }
    }

    // MARK: - Session lifecycle

    private func removeOverlay(id: UInt32) {
        sessions.removeValue(forKey: id)?.teardown()
    }

    private func handleClick(windowID: UInt32) {
        onOverlayClicked?()
        guard let plan = try? activatePinnedWindowUseCase.execute(
            ActivatePinnedWindowRequest(windowID: windowID)
        ) else { return }
        apply(plan)
    }

    private func createOverlay(_ placement: OverlayPlacementResponse) async {
        let id = placement.windowID
        guard sessions[id] == nil else { return }

        let monitor = CaptureMonitor(
            windowID: id,
            fps: placement.fps,
            manageCaptureStream: manageCaptureStream,
            captureWindow: captureWindow,
            observeCaptureFrames: observeCaptureFrames
        )
        let session = OverlaySession(windowID: id, monitor: monitor)
        sessions[id] = session

        var initialFrame: CaptureResponse?
        monitor.onFrameCaptured = { initialFrame = $0 }
        await monitor.start()

        guard let frame = initialFrame else {
            sessions.removeValue(forKey: id)?.teardown()
            return
        }
        // The window may have been unpinned during the async start above; our session would have
        // been cleared. Re-creating now would resurrect a removed overlay, so abort.
        guard sessions[id] === session else {
            session.teardown()
            return
        }

        let window = OverlayWindow(targetWindowID: id, initialFrame: frame, resolver: resolver)
        window.inactiveOpacity = CGFloat(placement.opacity)
        window.onClicked = { [weak self] wid in self?.handleClick(windowID: wid) }

        monitor.onFrameCaptured = { [weak window] response in window?.updateFrame(response) }
        monitor.onTargetLost = { [weak self] in
            self?.removeOverlay(id: id)
            self?.onTargetLost?(id)
        }

        session.attach(window)
        window.orderFront(nil)

        // If this window is already the active pin, it must start paused (hidden behind its real window).
        if !placement.isCaptureActive { monitor.teardown() }
    }
}
