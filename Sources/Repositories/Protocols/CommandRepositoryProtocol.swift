protocol CommandRepositoryProtocol: Sendable {
    func execute(_ command: WatchCommand) async throws
}
