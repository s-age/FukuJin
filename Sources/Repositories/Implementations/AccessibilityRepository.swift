final class AccessibilityRepository: AccessibilityRepositoryProtocol, Sendable {
    private let dataSource: any AccessibilityDataSourceProtocol

    init(dataSource: any AccessibilityDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func raiseWindow(windowID: UInt32, pid: Int32) {
        dataSource.raiseWindow(windowID: windowID, pid: pid)
    }

    func requestAccessibilityPermission() {
        dataSource.requestAccessibilityPermission()
    }
}
