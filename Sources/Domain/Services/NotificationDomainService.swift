final class NotificationDomainService: NotificationDomainServiceProtocol, Sendable {
    private let notificationRepository: any NotificationRepositoryProtocol

    init(notificationRepository: any NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    func send(title: String, body: String) async throws {
        try await notificationRepository.sendNotification(title: title, body: body)
    }
}
