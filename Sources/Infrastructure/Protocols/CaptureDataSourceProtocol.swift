import CoreGraphics

protocol CaptureDataSourceProtocol: Sendable {
    func startCapture(windowID: UInt32, fps: Double) async throws
    func stopCapture(windowID: UInt32) async
    func updateFPS(windowID: UInt32, fps: Double) async throws
    func captureWindow(_ windowID: UInt32) -> CGImage?
    func captureWindowOneShot(_ windowID: UInt32) async throws -> CGImage
    func getWindowBounds(_ windowID: UInt32) -> CGRect?
    func preflightCaptureAccess() -> Bool
    func requestCaptureAccess()
    func observeFrames(windowID: UInt32) -> AsyncStream<CGImage>
}
