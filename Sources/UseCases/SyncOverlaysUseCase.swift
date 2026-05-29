final class SyncOverlaysUseCase: SyncUseCase, Sendable {
    private let overlayService: any OverlayDomainServiceProtocol

    init(overlayService: any OverlayDomainServiceProtocol) {
        self.overlayService = overlayService
    }

    func execute(_ request: SyncOverlaysRequest) throws -> OverlayPlanResponse {
        OverlayPlanResponse(from: overlayService.sync(activationPID: request.activationPID))
    }
}
