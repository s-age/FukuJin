final class WindowZOrderRepository: WindowZOrderRepositoryProtocol, Sendable {
    private let dataSource: any WindowZOrderDataSourceProtocol

    init(dataSource: any WindowZOrderDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32) {
        dataSource.orderWindow(windowID, below: relativeWindowID)
    }
}
