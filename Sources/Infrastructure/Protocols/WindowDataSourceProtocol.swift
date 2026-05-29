protocol WindowDataSourceProtocol: Sendable {
    func listVisibleWindows() -> [WindowDTO]
}
