struct ManageCaptureStreamRequest: UseCaseRequest, Sendable {
    enum Action: Sendable {
        case start(fps: Double)
        case stop
        case updateFPS(Double)
    }

    let windowID: UInt32
    let action: Action

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        switch action {
        case .start(let fps), .updateFPS(let fps):
            guard fps >= 1.0, fps <= 60.0 else { throw ValidationError.invalidFPS }
        case .stop:
            break
        }
    }
}
