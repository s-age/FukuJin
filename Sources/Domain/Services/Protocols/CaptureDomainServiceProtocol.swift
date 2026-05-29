protocol CaptureDomainServiceProtocol: Sendable {
    func startCapture(windowID: UInt32, fps: Double) async throws
    func stopCapture(windowID: UInt32) async
    func updateFPS(windowID: UInt32, fps: Double) async throws
    func capture(windowID: UInt32) -> CapturedImageRef?
    func captureOneShot(windowID: UInt32) async throws -> CapturedImageRef
    func ensureCaptureAccess()
    func observeFrames(windowID: UInt32) -> AsyncStream<CapturedImageRef>
}
