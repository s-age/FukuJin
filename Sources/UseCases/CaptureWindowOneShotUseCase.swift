final class CaptureWindowOneShotUseCase: AsyncUseCase, Sendable {
    private let captureService: any CaptureDomainServiceProtocol

    init(captureService: any CaptureDomainServiceProtocol) {
        self.captureService = captureService
    }

    func execute(_ request: CaptureWindowOneShotRequest) async throws -> CapturedImageRefResponse {
        let entity = try await captureService.captureOneShot(windowID: request.windowID)
        return CapturedImageRefResponse(from: entity)
    }
}
