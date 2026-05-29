final class InfrastructureContainer {
    let windowDataSource: any WindowDataSourceProtocol
    let captureDataSource: any CaptureDataSourceProtocol
    let accessibilityDataSource: any AccessibilityDataSourceProtocol
    let workspaceDataSource: any WorkspaceDataSourceProtocol
    let windowZOrderDataSource: any WindowZOrderDataSourceProtocol
    let textRecognitionDataSource: any TextRecognitionDataSourceProtocol
    let notificationDataSource: any NotificationDataSourceProtocol
    let commandDataSource: any CommandDataSourceProtocol
    let loginItemDataSource: any LoginItemDataSourceProtocol
    let settingsDataSource: any SettingsDataSourceProtocol
    let capturedImageStore: any CapturedImageStoreProtocol

    init() {
        windowDataSource = WindowDataSource()
        captureDataSource = CaptureDataSource()
        accessibilityDataSource = AccessibilityDataSource()
        workspaceDataSource = WorkspaceDataSource()
        windowZOrderDataSource = WindowZOrderDataSource()
        textRecognitionDataSource = TextRecognitionDataSource()
        notificationDataSource = NotificationDataSource()
        commandDataSource = CommandDataSource()
        loginItemDataSource = LoginItemDataSource()
        settingsDataSource = SettingsDataSource()
        capturedImageStore = CapturedImageStore()
    }
}
