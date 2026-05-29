final class GetFrontmostWindowUseCase: SyncUseCase, Sendable {
    private let discoveryService: any WindowDiscoveryDomainServiceProtocol

    init(discoveryService: any WindowDiscoveryDomainServiceProtocol) {
        self.discoveryService = discoveryService
    }

    func execute(_ request: GetFrontmostWindowRequest) throws -> UInt32? {
        discoveryService.frontmostWindowID(ownedBy: request.ownerPID)
    }
}
