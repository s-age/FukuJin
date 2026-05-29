final class NotificationRepository: NotificationRepositoryProtocol, Sendable {
    private let dataSource: any NotificationDataSourceProtocol

    init(dataSource: any NotificationDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func sendNotification(title: String, body: String) async throws {
        try await dataSource.sendNotification(title: title, body: body)
    }

    func requestAuthorization() async throws {
        try await dataSource.requestAuthorization()
    }
}
