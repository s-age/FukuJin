struct OverlayPlacementResponse: Equatable, Sendable {
    let windowID: UInt32
    let opacity: Double
    let fps: Double
    let isCaptureActive: Bool
}

struct OverlayPlanResponse: Equatable, Sendable {
    let anchorWindowID: UInt32?
    let placements: [OverlayPlacementResponse]

    init(from plan: OverlayPlan) {
        anchorWindowID = plan.anchorWindowID
        placements = plan.placements.map {
            OverlayPlacementResponse(
                windowID: $0.windowID, opacity: $0.opacity, fps: $0.fps, isCaptureActive: $0.isCaptureActive
            )
        }
    }
}
