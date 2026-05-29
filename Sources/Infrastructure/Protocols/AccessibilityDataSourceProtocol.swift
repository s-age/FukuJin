import Foundation

protocol AccessibilityDataSourceProtocol: Sendable {
    func raiseWindow(windowID: UInt32, pid: Int32)
    func requestAccessibilityPermission()
}
