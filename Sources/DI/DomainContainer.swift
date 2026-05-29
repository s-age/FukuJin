final class DomainContainer: Sendable {
    let pinService: any PinDomainServiceProtocol
    let windowDiscoveryService: any WindowDiscoveryDomainServiceProtocol
    let captureService: any CaptureDomainServiceProtocol
    let windowActionService: any WindowActionDomainServiceProtocol
    let textWatchService: any TextWatchDomainServiceProtocol
    let recognitionSettingsService: any RecognitionSettingsDomainServiceProtocol
    let notificationService: any NotificationDomainServiceProtocol
    let permissionService: any PermissionDomainServiceProtocol
    let launchAtLoginService: any LaunchAtLoginDomainServiceProtocol
    let appIconService: any AppIconDomainServiceProtocol
    let overlayPolicyService: any OverlayPolicyDomainServiceProtocol
    let overlayService: any OverlayDomainServiceProtocol

    init(repositories: RepositoryContainer) {
        pinService = PinDomainService(settingsRepository: repositories.settingsRepository)
        windowDiscoveryService = WindowDiscoveryDomainService(repository: repositories.windowRepository)
        captureService = CaptureDomainService(
            lifecycleRepository: repositories.captureLifecycleRepository,
            snapshotRepository: repositories.captureSnapshotRepository,
            permissionRepository: repositories.capturePermissionRepository
        )
        let actionService = WindowActionDomainService(
            accessibilityRepository: repositories.accessibilityRepository,
            workspaceRepository: repositories.workspaceRepository,
            zOrderRepository: repositories.windowZOrderRepository
        )
        windowActionService = actionService
        textWatchService = TextWatchDomainService(
            textRecognitionRepository: repositories.textRecognitionRepository,
            commandRepository: repositories.commandRepository,
            windowActionService: actionService,
            settingsRepository: repositories.settingsRepository
        )
        recognitionSettingsService = RecognitionSettingsDomainService(
            settingsRepository: repositories.settingsRepository
        )
        notificationService = NotificationDomainService(
            notificationRepository: repositories.notificationRepository
        )
        permissionService = PermissionDomainService(
            accessibilityRepository: repositories.accessibilityRepository,
            captureRepository: repositories.capturePermissionRepository,
            notificationRepository: repositories.notificationRepository
        )
        launchAtLoginService = LaunchAtLoginDomainService(repository: repositories.loginItemRepository)
        appIconService = AppIconDomainService(
            appIconRepository: repositories.appIconRepository
        )
        let overlayPolicy = OverlayPolicyDomainService()
        overlayPolicyService = overlayPolicy
        overlayService = OverlayDomainService(
            pinService: pinService,
            actionService: actionService,
            discoveryService: windowDiscoveryService,
            policy: overlayPolicy
        )
    }
}
