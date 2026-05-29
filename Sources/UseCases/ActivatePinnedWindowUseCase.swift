final class ActivatePinnedWindowUseCase: SyncUseCase, Sendable {
    private let overlayService: any OverlayDomainServiceProtocol

    init(overlayService: any OverlayDomainServiceProtocol) {
        self.overlayService = overlayService
    }

    func execute(_ request: ActivatePinnedWindowRequest) throws -> OverlayPlanResponse {
        OverlayPlanResponse(from: overlayService.activate(windowID: request.windowID))
    }
}
