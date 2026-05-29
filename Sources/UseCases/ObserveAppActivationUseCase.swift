final class ObserveAppActivationUseCase: SyncUseCase, Sendable {
    private let actionService: any WindowActionDomainServiceProtocol

    init(actionService: any WindowActionDomainServiceProtocol) {
        self.actionService = actionService
    }

    func execute(_ request: ObserveAppActivationRequest) throws -> AsyncStream<Int32> {
        actionService.observeAppActivation()
    }
}
