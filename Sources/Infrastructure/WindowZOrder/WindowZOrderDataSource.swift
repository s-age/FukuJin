import CGSPrivate
import os

final class WindowZOrderDataSource: WindowZOrderDataSourceProtocol, Sendable {
    private static let logger = Logger(subsystem: "com.fukujin.app", category: "window-zorder")

    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32) {
        let cid = CGSMainConnectionID()
        // place = -1 (kCGSOrderBelow): order `windowID` below `relativeWindowID`.
        // CGS works at a lower layer than NSWindow.Level, so this can place a
        // floating overlay underneath a normal-level real window.
        let result = CGSOrderWindow(cid, windowID, -1, relativeWindowID)
        if result != .success {
            Self.logger.warning(
                "CGSOrderWindow(\(windowID), below: \(relativeWindowID)) returned \(result.rawValue)"
            )
        }
    }
}
