final class UpdateLaunchAtLoginUseCase: SyncUseCase, Sendable {
    private let launchAtLoginService: any LaunchAtLoginDomainServiceProtocol

    init(launchAtLoginService: any LaunchAtLoginDomainServiceProtocol) {
        self.launchAtLoginService = launchAtLoginService
    }

    func execute(_ request: UpdateLaunchAtLoginRequest) throws -> Bool {
        try launchAtLoginService.setEnabled(request.enabled)
        return launchAtLoginService.isEnabled()
    }
}
