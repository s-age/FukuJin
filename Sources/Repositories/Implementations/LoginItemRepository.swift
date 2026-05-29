final class LoginItemRepository: LoginItemRepositoryProtocol, Sendable {
    private let dataSource: any LoginItemDataSourceProtocol

    init(dataSource: any LoginItemDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func isEnabled() -> Bool {
        dataSource.isEnabled()
    }

    func setEnabled(_ enabled: Bool) throws {
        try dataSource.setEnabled(enabled)
    }
}
