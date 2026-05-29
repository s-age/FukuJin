final class WindowRepository: WindowRepositoryProtocol, Sendable {
    private let dataSource: any WindowDataSourceProtocol

    init(dataSource: any WindowDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func listVisibleWindows() -> [WindowInfo] {
        dataSource.listVisibleWindows().map { dto in
            WindowInfo(
                id: dto.windowID,
                ownerPID: dto.ownerPID,
                ownerName: dto.ownerName,
                windowName: dto.windowName
            )
        }
    }
}
