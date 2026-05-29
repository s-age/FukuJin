final class RequestAppPermissionsUseCase: AsyncUseCase, Sendable {
    private let permissionService: any PermissionDomainServiceProtocol

    init(permissionService: any PermissionDomainServiceProtocol) {
        self.permissionService = permissionService
    }

    func execute(_ request: RequestAppPermissionsRequest) async throws {
        await permissionService.requestAll()
    }
}
