final class UnpinWindowUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UnpinWindowRequest) throws -> PinnedWindowListResponse {
        let state = pinService.unpin(request.windowID)
        return PinnedWindowListResponse(from: state)
    }
}
