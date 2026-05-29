final class PinWindowUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: PinWindowRequest) throws -> PinnedWindowListResponse {
        let window = WindowInfo(
            id: request.windowID,
            ownerPID: request.ownerPID,
            ownerName: request.ownerName,
            windowName: request.windowName
        )
        let config = OverlayConfig.create(opacity: request.opacity, fps: request.fps)
        let state = pinService.pin(window, config: config)
        return PinnedWindowListResponse(from: state)
    }
}
