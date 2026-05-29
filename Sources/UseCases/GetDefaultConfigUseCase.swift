final class GetDefaultConfigUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: GetDefaultConfigRequest) throws -> OverlayConfigResponse {
        OverlayConfigResponse(from: pinService.defaultConfig())
    }
}
