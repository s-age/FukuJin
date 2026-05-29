final class CaptureWindowUseCase: SyncUseCase, Sendable {
    private let captureService: any CaptureDomainServiceProtocol

    init(captureService: any CaptureDomainServiceProtocol) {
        self.captureService = captureService
    }

    func execute(_ request: CaptureWindowRequest) throws -> CaptureResponse? {
        guard let entity = captureService.capture(windowID: request.windowID) else {
            return nil
        }
        return CaptureResponse(from: entity)
    }
}
