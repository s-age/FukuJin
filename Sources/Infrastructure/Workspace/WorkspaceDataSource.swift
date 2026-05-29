import AppKit
import Synchronization

final class WorkspaceDataSource: WorkspaceDataSourceProtocol, Sendable {
    func observeAppActivation() -> AsyncStream<Int32> {
        let center = NSWorkspace.shared.notificationCenter
        // Our own activation carries no overlay-focus signal: our windows are excluded from
        // `CGWindowList`, so resolving a frontmost pinned window always yields nil — which would
        // *clear* the focus authority. Worse, clicking an overlay activates us, so this fires
        // mid-click and races the click's explicit focus (overlay flickers back, needs a 2nd click).
        // Drop self-PID at the source, mirroring `WindowDataSource`'s self-exclusion.
        let selfPID = ProcessInfo.processInfo.processIdentifier
        return AsyncStream { continuation in
            let observer = center.addObserver(
                forName: NSWorkspace.didActivateApplicationNotification,
                object: nil,
                queue: .main
            ) { notification in
                guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                        as? NSRunningApplication else { return }
                guard app.processIdentifier != selfPID else { return }
                continuation.yield(app.processIdentifier)
            }
            let observerBox = Mutex<(any NSObjectProtocol)?>(observer)
            continuation.onTermination = { _ in
                observerBox.withLock { box in
                    if let observer = box { center.removeObserver(observer) }
                    box = nil
                }
            }
        }
    }

    func frontmostApplicationPID() -> Int32? {
        NSWorkspace.shared.frontmostApplication?.processIdentifier
    }

    func activateApp(pid: Int32) {
        if Thread.isMainThread {
            NSRunningApplication(processIdentifier: pid)?.activate()
        } else {
            DispatchQueue.main.async {
                NSRunningApplication(processIdentifier: pid)?.activate()
            }
        }
    }

    func appIcon(for bundleIdentifier: String?, localizedName: String?) -> Data? {
        let apps = NSWorkspace.shared.runningApplications
        let match = apps.first { app in
            if let bid = bundleIdentifier, app.bundleIdentifier == bid { return true }
            if let name = localizedName, app.localizedName == name { return true }
            return false
        }
        guard let icon = match?.icon,
              let tiff = icon.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:])
        else {
            return nil
        }
        return png
    }
}
