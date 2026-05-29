final class UpdateOpacityUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UpdateOpacityRequest) throws -> PinnedWindowListResponse {
        let state = try pinService.mutateWindow(windowID: request.windowID) { window in
            window.applyingOpacity(request.opacity)
        }
        return PinnedWindowListResponse(from: state)
    }
}
