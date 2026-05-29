protocol NotificationDomainServiceProtocol: Sendable {
    func send(title: String, body: String) async throws
}
