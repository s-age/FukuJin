final class PermissionDomainService: PermissionDomainServiceProtocol, Sendable {
    private let accessibilityRepository: any AccessibilityRepositoryProtocol
    private let captureRepository: any CapturePermissionRepositoryProtocol
    private let notificationRepository: any NotificationRepositoryProtocol

    init(
        accessibilityRepository: any AccessibilityRepositoryProtocol,
        captureRepository: any CapturePermissionRepositoryProtocol,
        notificationRepository: any NotificationRepositoryProtocol
    ) {
        self.accessibilityRepository = accessibilityRepository
        self.captureRepository = captureRepository
        self.notificationRepository = notificationRepository
    }

    func requestAll() async {
        accessibilityRepository.requestAccessibilityPermission()
        captureRepository.ensureCaptureAccess()
        try? await notificationRepository.requestAuthorization()
    }
}
