import SwiftUI

@Observable
@MainActor
final class MenuBarViewModel {
    private(set) var windowGroups: [WindowGroupResponse] = []
    private(set) var pinnedWindows: PinnedWindowListResponse = .empty
    private(set) var launchAtLogin: Bool = false
    private(set) var isInitializing: Bool = true

    private let listWindows: ListWindowsUseCaseProtocol
    private let pinWindow: PinWindowUseCaseProtocol
    private let unpinWindow: UnpinWindowUseCaseProtocol
    private let unpinAll: UnpinAllUseCaseProtocol
    private let updateOpacityUseCase: UpdateOpacityUseCaseProtocol
    private let updateFPSUseCase: UpdateFPSUseCaseProtocol
    private let getDefaultConfig: GetDefaultConfigUseCaseProtocol
    private let reorderPinnedWindowsUseCase: ReorderPinnedWindowsUseCaseProtocol
    private let getLaunchAtLogin: GetLaunchAtLoginUseCaseProtocol
    private let updateLaunchAtLoginUseCase: UpdateLaunchAtLoginUseCaseProtocol
    private let getAppIcon: GetAppIconUseCaseProtocol
    private let updateScanConfig: UpdateScanConfigUseCaseProtocol
    private let decodeAppIcon: @Sendable (Data) -> Image?

    @ObservationIgnored private var iconCache: [String: Image] = [:]

    let overlayManager: OverlayManager

    init(
        listWindows: ListWindowsUseCaseProtocol,
        pinWindow: PinWindowUseCaseProtocol,
        unpinWindow: UnpinWindowUseCaseProtocol,
        unpinAll: UnpinAllUseCaseProtocol,
        updateOpacity: UpdateOpacityUseCaseProtocol,
        updateFPS: UpdateFPSUseCaseProtocol,
        getDefaultConfig: GetDefaultConfigUseCaseProtocol,
        reorderPinnedWindows: ReorderPinnedWindowsUseCaseProtocol,
        getLaunchAtLogin: GetLaunchAtLoginUseCaseProtocol,
        updateLaunchAtLogin: UpdateLaunchAtLoginUseCaseProtocol,
        getAppIcon: GetAppIconUseCaseProtocol,
        updateScanConfig: UpdateScanConfigUseCaseProtocol,
        decodeAppIcon: @escaping @Sendable (Data) -> Image?,
        overlayManager: OverlayManager
    ) {
        self.listWindows = listWindows
        self.pinWindow = pinWindow
        self.unpinWindow = unpinWindow
        self.unpinAll = unpinAll
        self.updateOpacityUseCase = updateOpacity
        self.updateFPSUseCase = updateFPS
        self.getDefaultConfig = getDefaultConfig
        self.reorderPinnedWindowsUseCase = reorderPinnedWindows
        self.getLaunchAtLogin = getLaunchAtLogin
        self.updateLaunchAtLoginUseCase = updateLaunchAtLogin
        self.getAppIcon = getAppIcon
        self.updateScanConfig = updateScanConfig
        self.decodeAppIcon = decodeAppIcon
        self.overlayManager = overlayManager
        self.launchAtLogin = (try? getLaunchAtLogin.execute(GetLaunchAtLoginRequest())) ?? false
        overlayManager.onTargetLost = { [weak self] windowID in
            self?.handleTargetLost(windowID: windowID)
        }
    }

    func appIcon(localizedName: String) -> Image? {
        if let cached = iconCache[localizedName] { return cached }
        let response = (try? getAppIcon.execute(
            GetAppIconRequest(bundleIdentifier: nil, localizedName: localizedName)
        )) ?? nil
        guard let pngData = response?.pngData, let image = decodeAppIcon(pngData) else { return nil }
        iconCache[localizedName] = image
        return image
    }

    func performInitialWarmUp(minimumSplashDuration: Duration = .milliseconds(800)) async {
        let start = ContinuousClock.now
        refreshWindows()
        let elapsed = ContinuousClock.now - start
        if elapsed < minimumSplashDuration {
            try? await Task.sleep(for: minimumSplashDuration - elapsed)
        }
        isInitializing = false
    }

    func refreshWindows() {
        let groups = (try? listWindows.execute(ListWindowsRequest())) ?? []
        let activeNames = Set(groups.map(\.appName))
        iconCache = iconCache.filter { activeNames.contains($0.key) }
        for name in activeNames where iconCache[name] == nil {
            _ = appIcon(localizedName: name)
        }
        windowGroups = groups
    }

    func togglePin(_ window: WindowInfoResponse) {
        if pinnedWindows[window.id] != nil {
            unpin(windowID: window.id)
        } else {
            let defaults = try? getDefaultConfig.execute(GetDefaultConfigRequest())
            let request = PinWindowRequest(
                windowID: window.id,
                ownerPID: window.ownerPID,
                ownerName: window.ownerName,
                windowName: window.windowName,
                opacity: defaults?.opacity ?? 0.5,
                fps: defaults?.fps ?? 1.0
            )
            pinnedWindows = (try? pinWindow.execute(request)) ?? pinnedWindows
            rebuildOverlays()
        }
    }

    /// Unpins by window ID. The menu bar's pinned section is driven by `pinnedWindows.windowIDs`
    /// (the same source the Settings modal reorders), so its rows carry only the window ID — not
    /// a full `WindowInfoResponse` — and unpin directly through this path.
    func unpin(windowID: UInt32) {
        pinnedWindows = (try? unpinWindow.execute(UnpinWindowRequest(windowID: windowID)))
            ?? pinnedWindows
        rebuildOverlays()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            launchAtLogin = try updateLaunchAtLoginUseCase.execute(UpdateLaunchAtLoginRequest(enabled: enabled))
        } catch {
            launchAtLogin = (try? getLaunchAtLogin.execute(GetLaunchAtLoginRequest())) ?? launchAtLogin
        }
    }

    func unpinAllWindows() {
        pinnedWindows = (try? unpinAll.execute(UnpinAllRequest())) ?? pinnedWindows
        overlayManager.teardownAll()
    }

    func updateOpacity(windowID: UInt32, _ value: Double) {
        let request = UpdateOpacityRequest(windowID: windowID, opacity: value)
        pinnedWindows = (try? updateOpacityUseCase.execute(request)) ?? pinnedWindows
        rebuildOverlays()
    }

    func updateFPS(windowID: UInt32, _ value: Double) {
        let request = UpdateFPSRequest(windowID: windowID, fps: value)
        pinnedWindows = (try? updateFPSUseCase.execute(request)) ?? pinnedWindows
        rebuildOverlays()
    }

    func updatePinnedWindows(_ newState: PinnedWindowListResponse) {
        pinnedWindows = newState
    }

    func reorderPinnedWindows(_ newOrder: [UInt32]) {
        let request = ReorderPinnedWindowsRequest(order: newOrder)
        guard let result = try? reorderPinnedWindowsUseCase.execute(request) else { return }
        pinnedWindows = result
        // Route through rebuildOverlays — not a bare applyOrdering — so the frontmost window is
        // re-resolved against the new order. Calling applyOrdering directly would reuse the
        // frontmost snapshot from the last sync, which can strand overlays at a stale anchor.
        rebuildOverlays()
    }

    func setHighlights(windowID: UInt32, boundingBoxes: [BoundingBoxResponse]) {
        overlayManager.setHighlights(for: windowID, boundingBoxes: boundingBoxes)
    }

    func setScanning(windowID: UInt32, _ isScanning: Bool) {
        let request = UpdateScanConfigRequest(
            windowID: windowID,
            searchText: nil,
            actions: nil,
            isScanning: isScanning
        )
        guard let result = try? updateScanConfig.execute(request) else { return }
        pinnedWindows = result
        rebuildOverlays()
    }

    func isScanning(windowID: UInt32) -> Bool {
        pinnedWindows[windowID]?.scan.isScanning ?? false
    }

    func handleAppActivation(pid: Int32) {
        guard pinnedWindows.hasPinnedWindows else { return }
        overlayManager.sync(activationPID: pid)
    }

    func handleTargetLost(windowID: UInt32) {
        pinnedWindows = (try? unpinWindow.execute(UnpinWindowRequest(windowID: windowID)))
            ?? pinnedWindows
        rebuildOverlays()
    }

    func pruneStaleWindows() {
        let activeIDs = Set(windowGroups.flatMap { $0.windows.map(\.id) })
        let staleIDs = pinnedWindows.windows.map(\.windowID).filter { !activeIDs.contains($0) }
        for id in staleIDs {
            pinnedWindows = (try? unpinWindow.execute(UnpinWindowRequest(windowID: id)))
                ?? pinnedWindows
        }
    }

    private func rebuildOverlays() {
        // Pin-state change (not activation-driven): the Domain keeps its authoritative focus and
        // recomputes the plan. Frontmost re-resolution lives in the Domain (OverlayDomainService).
        overlayManager.sync(activationPID: nil)
    }
}
