final class UseCaseContainer: Sendable {
    let listWindows: ListWindowsUseCaseProtocol
    let pinWindow: PinWindowUseCaseProtocol
    let unpinWindow: UnpinWindowUseCaseProtocol
    let unpinAll: UnpinAllUseCaseProtocol
    let captureWindow: CaptureWindowUseCaseProtocol
    let raiseWindow: RaiseWindowUseCaseProtocol
    let updateOpacity: UpdateOpacityUseCaseProtocol
    let updateFPS: UpdateFPSUseCaseProtocol
    let manageCaptureStream: ManageCaptureStreamUseCaseProtocol
    let getDefaultConfig: GetDefaultConfigUseCaseProtocol
    let updateDefaultConfig: UpdateDefaultConfigUseCaseProtocol
    let scanText: ScanTextUseCaseProtocol
    let updateScanConfig: UpdateScanConfigUseCaseProtocol
    let executeTextWatchAction: ExecuteTextWatchActionUseCaseProtocol
    let sendNotification: SendNotificationUseCaseProtocol
    let captureWindowOneShot: CaptureWindowOneShotUseCaseProtocol
    let reorderPinnedWindows: ReorderPinnedWindowsUseCaseProtocol
    let orderWindowBelow: OrderWindowBelowUseCaseProtocol
    let requestAppPermissions: RequestAppPermissionsUseCaseProtocol
    let observeAppActivation: ObserveAppActivationUseCaseProtocol
    let getLaunchAtLogin: GetLaunchAtLoginUseCaseProtocol
    let updateLaunchAtLogin: UpdateLaunchAtLoginUseCaseProtocol
    let observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol
    let getAppIcon: GetAppIconUseCaseProtocol
    let getFrontmostWindow: GetFrontmostWindowUseCaseProtocol
    let syncOverlays: SyncOverlaysUseCaseProtocol
    let activatePinnedWindow: ActivatePinnedWindowUseCaseProtocol
    let getRecognitionLanguages: GetRecognitionLanguagesUseCaseProtocol
    let updateRecognitionLanguages: UpdateRecognitionLanguagesUseCaseProtocol

    init(domain: DomainContainer) {
        listWindows = ValidationSyncUseCaseDecorator(
            decoratee: ListWindowsUseCase(discoveryService: domain.windowDiscoveryService)
        )
        getFrontmostWindow = ValidationSyncUseCaseDecorator(
            decoratee: GetFrontmostWindowUseCase(discoveryService: domain.windowDiscoveryService)
        )
        pinWindow = ValidationSyncUseCaseDecorator(
            decoratee: PinWindowUseCase(pinService: domain.pinService)
        )
        unpinWindow = ValidationSyncUseCaseDecorator(
            decoratee: UnpinWindowUseCase(pinService: domain.pinService)
        )
        unpinAll = ValidationSyncUseCaseDecorator(
            decoratee: UnpinAllUseCase(pinService: domain.pinService)
        )
        captureWindow = ValidationSyncUseCaseDecorator(
            decoratee: CaptureWindowUseCase(captureService: domain.captureService)
        )
        raiseWindow = ValidationSyncUseCaseDecorator(
            decoratee: RaiseWindowUseCase(actionService: domain.windowActionService)
        )
        updateOpacity = ValidationSyncUseCaseDecorator(
            decoratee: UpdateOpacityUseCase(pinService: domain.pinService)
        )
        updateFPS = ValidationSyncUseCaseDecorator(
            decoratee: UpdateFPSUseCase(pinService: domain.pinService)
        )
        manageCaptureStream = ValidationAsyncUseCaseDecorator(
            decoratee: ManageCaptureStreamUseCase(captureService: domain.captureService)
        )
        getDefaultConfig = ValidationSyncUseCaseDecorator(
            decoratee: GetDefaultConfigUseCase(pinService: domain.pinService)
        )
        updateDefaultConfig = ValidationSyncUseCaseDecorator(
            decoratee: UpdateDefaultConfigUseCase(pinService: domain.pinService)
        )
        scanText = ValidationAsyncUseCaseDecorator(
            decoratee: ScanTextUseCase(textWatchService: domain.textWatchService)
        )
        updateScanConfig = ValidationSyncUseCaseDecorator(
            decoratee: UpdateScanConfigUseCase(pinService: domain.pinService)
        )
        executeTextWatchAction = ValidationAsyncUseCaseDecorator(
            decoratee: ExecuteTextWatchActionUseCase(textWatchService: domain.textWatchService)
        )
        sendNotification = ValidationAsyncUseCaseDecorator(
            decoratee: SendNotificationUseCase(notificationService: domain.notificationService)
        )
        captureWindowOneShot = ValidationAsyncUseCaseDecorator(
            decoratee: CaptureWindowOneShotUseCase(captureService: domain.captureService)
        )
        reorderPinnedWindows = ValidationSyncUseCaseDecorator(
            decoratee: ReorderPinnedWindowsUseCase(pinService: domain.pinService)
        )
        orderWindowBelow = ValidationSyncUseCaseDecorator(
            decoratee: OrderWindowBelowUseCase(actionService: domain.windowActionService)
        )
        requestAppPermissions = ValidationAsyncUseCaseDecorator(
            decoratee: RequestAppPermissionsUseCase(permissionService: domain.permissionService)
        )
        observeAppActivation = ValidationSyncUseCaseDecorator(
            decoratee: ObserveAppActivationUseCase(actionService: domain.windowActionService)
        )
        getLaunchAtLogin = ValidationSyncUseCaseDecorator(
            decoratee: GetLaunchAtLoginUseCase(launchAtLoginService: domain.launchAtLoginService)
        )
        updateLaunchAtLogin = ValidationSyncUseCaseDecorator(
            decoratee: UpdateLaunchAtLoginUseCase(launchAtLoginService: domain.launchAtLoginService)
        )
        observeCaptureFrames = ValidationSyncUseCaseDecorator(
            decoratee: ObserveCaptureFramesUseCase(captureService: domain.captureService)
        )
        getAppIcon = ValidationSyncUseCaseDecorator(
            decoratee: GetAppIconUseCase(appIconService: domain.appIconService)
        )
        syncOverlays = ValidationSyncUseCaseDecorator(
            decoratee: SyncOverlaysUseCase(overlayService: domain.overlayService)
        )
        activatePinnedWindow = ValidationSyncUseCaseDecorator(
            decoratee: ActivatePinnedWindowUseCase(overlayService: domain.overlayService)
        )
        getRecognitionLanguages = ValidationSyncUseCaseDecorator(
            decoratee: GetRecognitionLanguagesUseCase(
                recognitionSettingsService: domain.recognitionSettingsService
            )
        )
        updateRecognitionLanguages = ValidationSyncUseCaseDecorator(
            decoratee: UpdateRecognitionLanguagesUseCase(
                recognitionSettingsService: domain.recognitionSettingsService
            )
        )
    }
}
