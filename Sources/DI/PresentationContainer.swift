import CoreGraphics
import Foundation

final class PresentationContainer: Sendable {
    private let listWindows: ListWindowsUseCaseProtocol
    private let pinWindow: PinWindowUseCaseProtocol
    private let unpinWindow: UnpinWindowUseCaseProtocol
    private let unpinAll: UnpinAllUseCaseProtocol
    private let captureWindow: CaptureWindowUseCaseProtocol
    private let updateOpacity: UpdateOpacityUseCaseProtocol
    private let updateFPS: UpdateFPSUseCaseProtocol
    private let manageCaptureStream: ManageCaptureStreamUseCaseProtocol
    private let getDefaultConfig: GetDefaultConfigUseCaseProtocol
    private let updateDefaultConfig: UpdateDefaultConfigUseCaseProtocol
    private let scanText: ScanTextUseCaseProtocol
    private let updateScanConfig: UpdateScanConfigUseCaseProtocol
    private let getRecognitionLanguages: GetRecognitionLanguagesUseCaseProtocol
    private let updateRecognitionLanguages: UpdateRecognitionLanguagesUseCaseProtocol
    private let executeTextWatchAction: ExecuteTextWatchActionUseCaseProtocol
    private let captureWindowOneShot: CaptureWindowOneShotUseCaseProtocol
    private let sendNotification: SendNotificationUseCaseProtocol
    private let reorderPinnedWindows: ReorderPinnedWindowsUseCaseProtocol
    private let orderWindowBelow: OrderWindowBelowUseCaseProtocol
    private let getLaunchAtLogin: GetLaunchAtLoginUseCaseProtocol
    private let updateLaunchAtLogin: UpdateLaunchAtLoginUseCaseProtocol
    private let observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol
    private let getAppIcon: GetAppIconUseCaseProtocol
    private let syncOverlays: SyncOverlaysUseCaseProtocol
    private let activatePinnedWindow: ActivatePinnedWindowUseCaseProtocol
    private let resolver: any CapturedImageResolverProtocol

    init(useCases: UseCaseContainer, resolveFrame: @escaping @Sendable (UInt32) -> CGImage?) {
        listWindows = useCases.listWindows
        pinWindow = useCases.pinWindow
        unpinWindow = useCases.unpinWindow
        unpinAll = useCases.unpinAll
        captureWindow = useCases.captureWindow
        updateOpacity = useCases.updateOpacity
        updateFPS = useCases.updateFPS
        manageCaptureStream = useCases.manageCaptureStream
        getDefaultConfig = useCases.getDefaultConfig
        updateDefaultConfig = useCases.updateDefaultConfig
        scanText = useCases.scanText
        updateScanConfig = useCases.updateScanConfig
        getRecognitionLanguages = useCases.getRecognitionLanguages
        updateRecognitionLanguages = useCases.updateRecognitionLanguages
        executeTextWatchAction = useCases.executeTextWatchAction
        captureWindowOneShot = useCases.captureWindowOneShot
        sendNotification = useCases.sendNotification
        reorderPinnedWindows = useCases.reorderPinnedWindows
        orderWindowBelow = useCases.orderWindowBelow
        getLaunchAtLogin = useCases.getLaunchAtLogin
        updateLaunchAtLogin = useCases.updateLaunchAtLogin
        observeCaptureFrames = useCases.observeCaptureFrames
        getAppIcon = useCases.getAppIcon
        syncOverlays = useCases.syncOverlays
        activatePinnedWindow = useCases.activatePinnedWindow
        resolver = CGImageCapturedImageResolver(resolveFrame: resolveFrame)
    }

    @MainActor
    func makeMenuBarViewModel() -> MenuBarViewModel {
        let overlayManager = OverlayManager(
            captureWindow: captureWindow,
            manageCaptureStream: manageCaptureStream,
            orderWindowBelow: orderWindowBelow,
            observeCaptureFrames: observeCaptureFrames,
            resolver: resolver,
            syncOverlays: syncOverlays,
            activatePinnedWindow: activatePinnedWindow
        )
        return MenuBarViewModel(
            listWindows: listWindows,
            pinWindow: pinWindow,
            unpinWindow: unpinWindow,
            unpinAll: unpinAll,
            updateOpacity: updateOpacity,
            updateFPS: updateFPS,
            getDefaultConfig: getDefaultConfig,
            reorderPinnedWindows: reorderPinnedWindows,
            getLaunchAtLogin: getLaunchAtLogin,
            updateLaunchAtLogin: updateLaunchAtLogin,
            getAppIcon: getAppIcon,
            updateScanConfig: updateScanConfig,
            decodeAppIcon: AppIconImageDecoder.decode,
            overlayManager: overlayManager
        )
    }

    @MainActor
    func makeSettingsViewModel(menuBarViewModel: MenuBarViewModel) -> SettingsViewModel {
        SettingsViewModel(
            menuBarViewModel: menuBarViewModel,
            getDefaultConfig: getDefaultConfig,
            updateDefaultConfig: updateDefaultConfig,
            updateScanConfig: updateScanConfig,
            getRecognitionLanguages: getRecognitionLanguages,
            updateRecognitionLanguages: updateRecognitionLanguages
        )
    }

    @MainActor
    func makeSettingsWindowHost(
        menuBarViewModel: MenuBarViewModel
    ) -> SwiftUIWindowHostBridge<SettingsRootView> {
        var heldViewModel: SettingsViewModel?

        return SwiftUIWindowHostBridge(
            config: .standardPanel(
                title: "FukuJin Settings",
                size: CGSize(width: 720, height: 500)
            ),
            content: { [self] in
                let viewModel = makeSettingsViewModel(menuBarViewModel: menuBarViewModel)
                heldViewModel = viewModel
                return SettingsRootView(viewModel: viewModel)
            },
            onWillClose: {
                if heldViewModel != nil {
                    heldViewModel = nil
                }
            }
        )
    }

    @MainActor
    func makeTextWatchCoordinator() -> TextWatchCoordinator {
        TextWatchCoordinator(
            scanText: scanText,
            executeAction: executeTextWatchAction,
            captureWindowOneShot: captureWindowOneShot,
            sendNotification: sendNotification
        )
    }
}
