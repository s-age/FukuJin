import AppKit

/// One pinned window's overlay mechanism: its capture monitor plus, once the first frame
/// arrives, its overlay window. The monitor is owned from session creation (it must start
/// before the window can be built); the window is attached later via `attach`. Removal at any
/// point tears both down. Replaces OverlayManager's former parallel windows/monitors dicts.
@MainActor
final class OverlaySession {
    let windowID: UInt32
    let monitor: CaptureMonitor
    private(set) var window: OverlayWindow?

    init(windowID: UInt32, monitor: CaptureMonitor) {
        self.windowID = windowID
        self.monitor = monitor
    }

    func attach(_ window: OverlayWindow) { self.window = window }

    func teardown() {
        monitor.teardown()
        window?.teardown()
    }
}
