final class OrderWindowBelowUseCase: SyncUseCase, Sendable {
    private let actionService: any WindowActionDomainServiceProtocol

    init(actionService: any WindowActionDomainServiceProtocol) {
        self.actionService = actionService
    }

    func execute(_ request: OrderWindowBelowRequest) throws {
        actionService.orderWindow(request.windowID, below: request.relativeWindowID)
    }
}
