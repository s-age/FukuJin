final class GetLaunchAtLoginUseCase: SyncUseCase, Sendable {
    private let launchAtLoginService: any LaunchAtLoginDomainServiceProtocol

    init(launchAtLoginService: any LaunchAtLoginDomainServiceProtocol) {
        self.launchAtLoginService = launchAtLoginService
    }

    func execute(_ request: GetLaunchAtLoginRequest) throws -> Bool {
        launchAtLoginService.isEnabled()
    }
}
