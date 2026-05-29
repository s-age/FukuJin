struct CaptureResponse: Equatable, Sendable {
    let image: CapturedImageRefResponse
}

extension CaptureResponse {
    init(from entity: CapturedImageRef) {
        self.init(image: CapturedImageRefResponse(from: entity))
    }
}
