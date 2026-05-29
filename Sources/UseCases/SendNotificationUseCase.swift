final class SendNotificationUseCase: AsyncUseCase, Sendable {
    private let notificationService: any NotificationDomainServiceProtocol

    init(notificationService: any NotificationDomainServiceProtocol) {
        self.notificationService = notificationService
    }

    func execute(_ request: SendNotificationRequest) async throws {
        try await notificationService.send(title: request.title, body: request.body)
    }
}
