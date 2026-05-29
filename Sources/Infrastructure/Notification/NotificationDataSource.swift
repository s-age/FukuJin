import Synchronization
import UserNotifications

final class NotificationDataSource: NSObject,
                                    NotificationDataSourceProtocol,
                                    UNUserNotificationCenterDelegate,
                                    Sendable {
    private let delegateConfigured: Mutex<Bool> = Mutex(false)

    private var hasBundle: Bool {
        Bundle.main.bundleIdentifier != nil
    }

    private func ensureDelegate() {
        guard hasBundle else { return }
        let shouldConfigure = delegateConfigured.withLock { configured -> Bool in
            guard !configured else { return false }
            configured = true
            return true
        }
        guard shouldConfigure else { return }
        UNUserNotificationCenter.current().delegate = self
    }

    func sendNotification(title: String, body: String) async throws {
        guard hasBundle else { return }
        ensureDelegate()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        try await UNUserNotificationCenter.current().add(request)
    }

    func requestAuthorization() async throws {
        guard hasBundle else { return }
        ensureDelegate()
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
