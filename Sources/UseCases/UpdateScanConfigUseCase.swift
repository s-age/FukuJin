final class UpdateScanConfigUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UpdateScanConfigRequest) throws -> PinnedWindowListResponse {
        let updated = try pinService.mutateWindow(windowID: request.windowID) { entry in
            var config = entry.scan
            if let searchText = request.searchText {
                config = config.applying(searchText: searchText)
            }
            if let actions = request.actions {
                config = config.applying(actions: try actions.map { try $0.toDomain })
            }
            if let isScanning = request.isScanning {
                config = config.applying(isScanning: isScanning)
            }
            var updated = entry
            updated.scan = config
            return updated
        }
        return PinnedWindowListResponse(from: updated)
    }
}
