final class OverlayPolicyDomainService: OverlayPolicyDomainServiceProtocol, Sendable {
    func plan(pinnedWindows: PinnedWindowList, focus: WindowFocusState) -> OverlayPlan {
        // Pure derivation: the caller (the focus authority in `OverlayDomainService`) guarantees a
        // `.focused` window is still pinned, so liveness is *not* re-validated here. Anchor = the
        // frontmost pinned window, at most one.
        let anchor = focus.focusedWindowID
        // pinnedWindows.windows order == z-order (front first). The anchor's overlay stays in the
        // list (ordered below its real window) but pauses capture since it is fully occluded.
        let placements = pinnedWindows.windows.map { window in
            OverlayPlacement(
                windowID: window.id,
                opacity: window.opacity,
                fps: window.fps,
                isCaptureActive: window.id != anchor
            )
        }
        return OverlayPlan(anchorWindowID: anchor, placements: placements)
    }
}
