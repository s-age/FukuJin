protocol CaptureSnapshotRepositoryProtocol: Sendable {
    func captureWindow(_ windowID: UInt32) -> CapturedImageRef?
    func captureWindowOneShot(_ windowID: UInt32) async throws -> CapturedImageRef
}
