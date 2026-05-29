protocol WindowRepositoryProtocol: Sendable {
    func listVisibleWindows() -> [WindowInfo]
}
