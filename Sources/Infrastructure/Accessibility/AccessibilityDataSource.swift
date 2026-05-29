import AppKit
import CGSPrivate
import os

final class AccessibilityDataSource: AccessibilityDataSourceProtocol, Sendable {
    private static let logger = Logger(subsystem: "com.fukujin.app", category: "accessibility")

    func raiseWindow(windowID: UInt32, pid: Int32) {
        let appRef = AXUIElementCreateApplication(pid)
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            appRef, kAXWindowsAttribute as CFString, &windowsRef
        ) == .success,
              let windows = windowsRef as? [AXUIElement]
        else { return }

        for window in windows {
            var wid: UInt32 = 0
            let result = _AXUIElementGetWindow(window, &wid)
            guard result == AXError.success.rawValue else {
                Self.logger.warning("_AXUIElementGetWindow returned \(result)")
                continue
            }
            if wid == windowID {
                AXUIElementPerformAction(window, kAXRaiseAction as CFString)
                return
            }
        }
    }

    func requestAccessibilityPermission() {
        let key = "AXTrustedCheckOptionPrompt" as CFString
        let options = [key: kCFBooleanTrue!] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
