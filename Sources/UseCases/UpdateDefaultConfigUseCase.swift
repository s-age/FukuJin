final class UpdateDefaultConfigUseCase: SyncUseCase, Sendable {
    private let pinService: any PinDomainServiceProtocol

    init(pinService: any PinDomainServiceProtocol) {
        self.pinService = pinService
    }

    func execute(_ request: UpdateDefaultConfigRequest) throws -> OverlayConfigResponse {
        var config = pinService.defaultConfig()
        if let opacity = request.opacity {
            config = config.applying(opacity: opacity)
        }
        if let fps = request.fps {
            config = config.applying(fps: fps)
        }
        let updated = try pinService.updateDefaultConfig(config)
        return OverlayConfigResponse(from: updated)
    }
}
