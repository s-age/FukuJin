import Foundation

final class AppIconDomainService: AppIconDomainServiceProtocol, Sendable {
    private let appIconRepository: any AppIconRepositoryProtocol

    init(appIconRepository: any AppIconRepositoryProtocol) {
        self.appIconRepository = appIconRepository
    }

    func appIcon(bundleIdentifier: String?, localizedName: String?) -> Data? {
        appIconRepository.appIcon(
            for: bundleIdentifier,
            localizedName: localizedName
        )
    }
}
