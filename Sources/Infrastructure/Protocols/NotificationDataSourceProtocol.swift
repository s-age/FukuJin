protocol NotificationDataSourceProtocol: Sendable {
    func sendNotification(title: String, body: String) async throws
    func requestAuthorization() async throws
}
