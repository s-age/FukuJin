final class RepositoryContainer: Sendable {
    let windowRepository: any WindowRepositoryProtocol
    let captureLifecycleRepository: any CaptureLifecycleRepositoryProtocol
    let captureSnapshotRepository: any CaptureSnapshotRepositoryProtocol
    let windowBoundsRepository: any WindowBoundsRepositoryProtocol
    let capturePermissionRepository: any CapturePermissionRepositoryProtocol
    let accessibilityRepository: any AccessibilityRepositoryProtocol
    let workspaceRepository: any WorkspaceRepositoryProtocol
    let appIconRepository: any AppIconRepositoryProtocol
    let windowZOrderRepository: any WindowZOrderRepositoryProtocol
    let textRecognitionRepository: any TextRecognitionRepositoryProtocol
    let notificationRepository: any NotificationRepositoryProtocol
    let commandRepository: any CommandRepositoryProtocol
    let loginItemRepository: any LoginItemRepositoryProtocol
    let settingsRepository: any SettingsRepositoryProtocol

    init(infrastructure: InfrastructureContainer) {
        windowRepository = WindowRepository(dataSource: infrastructure.windowDataSource)
        let captureRepository = CaptureRepository(
            dataSource: infrastructure.captureDataSource,
            imageStore: infrastructure.capturedImageStore
        )
        captureLifecycleRepository = captureRepository
        captureSnapshotRepository = captureRepository
        windowBoundsRepository = captureRepository
        capturePermissionRepository = captureRepository
        accessibilityRepository = AccessibilityRepository(dataSource: infrastructure.accessibilityDataSource)
        let workspaceRepo = WorkspaceRepository(dataSource: infrastructure.workspaceDataSource)
        workspaceRepository = workspaceRepo
        appIconRepository = workspaceRepo
        windowZOrderRepository = WindowZOrderRepository(dataSource: infrastructure.windowZOrderDataSource)
        textRecognitionRepository = TextRecognitionRepository(
            dataSource: infrastructure.textRecognitionDataSource,
            imageStore: infrastructure.capturedImageStore
        )
        notificationRepository = NotificationRepository(dataSource: infrastructure.notificationDataSource)
        commandRepository = CommandRepository(dataSource: infrastructure.commandDataSource)
        loginItemRepository = LoginItemRepository(dataSource: infrastructure.loginItemDataSource)
        settingsRepository = SettingsRepository(dataSource: infrastructure.settingsDataSource)
    }
}
