final class UnpinAllUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UnpinAllRequest) throws -> PinnedWindowListResponse {
        let state = pinService.unpinAll()
        return PinnedWindowListResponse(from: state)
    }
}
