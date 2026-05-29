final class LaunchAtLoginDomainService: LaunchAtLoginDomainServiceProtocol, Sendable {
    private let repository: any LoginItemRepositoryProtocol

    init(repository: any LoginItemRepositoryProtocol) {
        self.repository = repository
    }

    func isEnabled() -> Bool {
        repository.isEnabled()
    }

    func setEnabled(_ enabled: Bool) throws {
        try repository.setEnabled(enabled)
    }
}
