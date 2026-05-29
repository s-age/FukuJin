final class CommandRepository: CommandRepositoryProtocol, Sendable {
    private let dataSource: any CommandDataSourceProtocol

    init(dataSource: any CommandDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func execute(_ command: WatchCommand) async throws {
        do {
            try await dataSource.execute(command.raw)
        } catch InfrastructureError.processExitedNonZero(let status) {
            throw DomainError.commandExitedWithNonZeroStatus(message: status)
        }
    }
}
