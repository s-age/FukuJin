final class ObserveCaptureFramesUseCase: SyncUseCase, Sendable {
    private let captureService: any CaptureDomainServiceProtocol

    init(captureService: any CaptureDomainServiceProtocol) {
        self.captureService = captureService
    }

    func execute(_ request: ObserveCaptureFramesRequest) throws -> AsyncStream<CaptureResponse> {
        let raw = captureService.observeFrames(windowID: request.windowID)
        return AsyncStream { continuation in
            let task = Task {
                for await entity in raw {
                    continuation.yield(CaptureResponse(from: entity))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
