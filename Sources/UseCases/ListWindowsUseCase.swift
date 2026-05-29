final class ListWindowsUseCase: SyncUseCase, Sendable {
    private let discoveryService: any WindowDiscoveryDomainServiceProtocol

    init(discoveryService: any WindowDiscoveryDomainServiceProtocol) {
        self.discoveryService = discoveryService
    }

    func execute(_ request: ListWindowsRequest) throws -> [WindowGroupResponse] {
        let windows = discoveryService.discoverWindows()
        let groups = discoveryService.groupByApp(windows)
        return groups.map { WindowGroupResponse(from: $0) }
    }
}
