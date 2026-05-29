protocol OverlayPolicyDomainServiceProtocol: Sendable {
    /// Pure function (no repository dependency). The migration target for
    /// `OverlayManager.computeActivePinIDs` + the ordering decision.
    func plan(pinnedWindows: PinnedWindowList, focus: WindowFocusState) -> OverlayPlan
}
