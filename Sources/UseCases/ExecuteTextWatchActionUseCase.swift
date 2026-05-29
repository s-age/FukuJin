final class ExecuteTextWatchActionUseCase: AsyncUseCase, Sendable {
    private let textWatchService: any TextWatchDomainServiceProtocol

    init(textWatchService: any TextWatchDomainServiceProtocol) {
        self.textWatchService = textWatchService
    }

    func execute(_ request: ExecuteTextWatchActionRequest) async throws -> ExecuteTextWatchActionResponse {
        let events = await textWatchService.executeActions(
            try request.actions.map { try $0.toDomain },
            windowID: request.windowID,
            pid: request.pid
        )
        return ExecuteTextWatchActionResponse(from: events)
    }
}
