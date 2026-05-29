final class GetAppIconUseCase: SyncUseCase, Sendable {
    private let appIconService: any AppIconDomainServiceProtocol

    init(appIconService: any AppIconDomainServiceProtocol) {
        self.appIconService = appIconService
    }

    func execute(_ request: GetAppIconRequest) throws -> AppIconResponse? {
        guard let data = appIconService.appIcon(
            bundleIdentifier: request.bundleIdentifier,
            localizedName: request.localizedName
        ) else {
            return nil
        }
        return AppIconResponse(pngData: data)
    }
}
