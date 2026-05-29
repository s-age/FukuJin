protocol CaptureLifecycleRepositoryProtocol: Sendable {
    func startCapture(windowID: UInt32, fps: Double) async throws
    func stopCapture(windowID: UInt32) async
    func updateFPS(windowID: UInt32, fps: Double) async throws
    func observeFrames(windowID: UInt32) -> AsyncStream<CapturedImageRef>
}
