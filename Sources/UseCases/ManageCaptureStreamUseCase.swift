final class ManageCaptureStreamUseCase: AsyncUseCase, Sendable {
    private let captureService: any CaptureDomainServiceProtocol

    init(captureService: any CaptureDomainServiceProtocol) {
        self.captureService = captureService
    }

    func execute(_ request: ManageCaptureStreamRequest) async throws {
        switch request.action {
        case .start(let fps):
            try await captureService.startCapture(windowID: request.windowID, fps: fps)
        case .stop:
            await captureService.stopCapture(windowID: request.windowID)
        case .updateFPS(let fps):
            try await captureService.updateFPS(windowID: request.windowID, fps: fps)
        }
    }
}
