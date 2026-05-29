protocol CommandDataSourceProtocol: Sendable {
    func execute(_ command: String) async throws
}
