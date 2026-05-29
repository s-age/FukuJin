final class UpdateFPSUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UpdateFPSRequest) throws -> PinnedWindowListResponse {
        let state = try pinService.mutateWindow(windowID: request.windowID) { window in
            window.applyingFPS(request.fps)
        }
        return PinnedWindowListResponse(from: state)
    }
}
