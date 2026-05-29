protocol OverlayDomainServiceProtocol: Sendable {
    /// Activate a pinned window (atomic): resolve its pid from pin state, raise its real window,
    /// update the authoritative focus, and return the new `OverlayPlan`. Applying the plan to the
    /// actual overlay windows is the Presentation layer's job (it owns the NSWindows).
    func activate(windowID: UInt32) -> OverlayPlan
    /// Sync after an app activation (reconcile the OS observation) or a pin-state change (`nil`).
    func sync(activationPID: Int32?) -> OverlayPlan
}
