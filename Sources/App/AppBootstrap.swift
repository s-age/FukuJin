import AppKit
import os
import SwiftUI

@MainActor
final class AppBootstrap: NSObject, NSApplicationDelegate {
    private static let logger = Logger(subsystem: "com.fukujin.app", category: "bootstrap")

    let menuBarViewModel: MenuBarViewModel
    let settingsWindowHost: SwiftUIWindowHostBridge<SettingsRootView>

    private let container: Container
    private let textWatchCoordinator: TextWatchCoordinator
    private var splashWindowHost: SwiftUIWindowHostBridge<SplashWindowView>?

    override init() {
        let splashHost = SwiftUIWindowHostBridge(
            config: .floatingSplash(size: CGSize(width: 280, height: 240)),
            content: { SplashWindowView() }
        )
        splashHost.show()

        let container = Container()
        let viewModel = container.presentation.makeMenuBarViewModel()
        let settingsHost = container.presentation.makeSettingsWindowHost(
            menuBarViewModel: viewModel
        )
        let coordinator = container.presentation.makeTextWatchCoordinator()

        self.container = container
        self.menuBarViewModel = viewModel
        self.settingsWindowHost = settingsHost
        self.textWatchCoordinator = coordinator
        self.splashWindowHost = splashHost
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Clicking an overlay raises another app (via `acceptsFirstMouse`), which bypasses the
        // MenuBarExtra popover's outside-click dismissal — and the popover does not close on app
        // resign-active either. So dismiss it explicitly here.
        menuBarViewModel.overlayManager.onOverlayClicked = { Self.dismissMenuBarExtraPopover() }

        textWatchCoordinator.onHighlightsChanged = { [weak menuBarViewModel] windowID, boxes in
            menuBarViewModel?.setHighlights(windowID: windowID, boundingBoxes: boxes)
        }
        textWatchCoordinator.onMatchDetected = { [weak menuBarViewModel] windowID in
            menuBarViewModel?.setScanning(windowID: windowID, false)
        }

        if let activationStream = try? container.useCases.observeAppActivation.execute(
            ObserveAppActivationRequest()
        ) {
            Task { @MainActor [weak menuBarViewModel] in
                for await pid in activationStream {
                    menuBarViewModel?.handleAppActivation(pid: pid)
                }
            }
        }

        // Screen-recording / accessibility permissions must be resolved before the
        // capture-driven text watch starts; otherwise the coordinator spins on a
        // stream that the OS rejects. Serialize: request permissions → start watch →
        // warm up → dismiss splash.
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await container.useCases.requestAppPermissions.execute(
                    RequestAppPermissionsRequest()
                )
            } catch {
                Self.logger.warning(
                    "App permission request failed: \(error.localizedDescription, privacy: .public)"
                )
            }

            textWatchCoordinator.start(
                pinnedWindowsProvider: { [weak menuBarViewModel] in
                    menuBarViewModel?.pinnedWindows ?? .empty
                }
            )

            await menuBarViewModel.performInitialWarmUp()
            splashWindowHost?.close()
            splashWindowHost = nil
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Order out the open `MenuBarExtra(.window)` popover, if any. SwiftUI exposes no programmatic
    /// dismiss for it, so we match its private panel class (`MenuBarExtraWindow`) among `NSApp`'s
    /// windows. Scoped by class name so other app windows (Settings, Splash) are never touched.
    private static func dismissMenuBarExtraPopover() {
        for window in NSApp.windows
        where window.isVisible && window.className.contains("MenuBarExtra") {
            window.orderOut(nil)
        }
    }
}
