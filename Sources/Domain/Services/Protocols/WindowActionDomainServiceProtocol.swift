protocol WindowActionDomainServiceProtocol: Sendable {
    func raiseWindow(windowID: UInt32, pid: Int32)
    func activateApp(pid: Int32)
    func requestAccessibilityPermission()
    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32)
    func observeAppActivation() -> AsyncStream<Int32>
}
