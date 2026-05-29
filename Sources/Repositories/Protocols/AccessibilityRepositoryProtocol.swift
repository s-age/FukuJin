protocol AccessibilityRepositoryProtocol: Sendable {
    func raiseWindow(windowID: UInt32, pid: Int32)
    func requestAccessibilityPermission()
}
