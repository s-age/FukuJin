import AppKit
import SwiftUI

@main
struct FukuJinApp: App {
    @NSApplicationDelegateAdaptor(AppBootstrap.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView(
                viewModel: appDelegate.menuBarViewModel,
                onShowSettings: { [appDelegate] in
                    appDelegate.settingsWindowHost.show()
                },
                onQuit: { NSApp.terminate(nil) }
            )
        } label: {
            if appDelegate.menuBarViewModel.isInitializing {
                Image(systemName: "ellipsis")
                    .symbolEffect(.variableColor, options: .repeating)
            } else {
                Image(systemName: appDelegate.menuBarViewModel.pinnedWindows.hasPinnedWindows
                    ? "pin.fill" : "pin")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
