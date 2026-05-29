final class RaiseWindowUseCase: SyncUseCase, Sendable {
    private let actionService: any WindowActionDomainServiceProtocol

    init(actionService: any WindowActionDomainServiceProtocol) {
        self.actionService = actionService
    }

    func execute(_ request: RaiseWindowRequest) throws {
        actionService.raiseWindow(windowID: request.windowID, pid: request.pid)
    }
}
