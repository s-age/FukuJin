final class ReorderPinnedWindowsUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: ReorderPinnedWindowsRequest) throws -> PinnedWindowListResponse {
        let state = pinService.reorder(request.order)
        return PinnedWindowListResponse(from: state)
    }
}
