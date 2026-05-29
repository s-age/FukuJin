final class CaptureDomainService: CaptureDomainServiceProtocol, Sendable {
    private let lifecycleRepository: any CaptureLifecycleRepositoryProtocol
    private let snapshotRepository: any CaptureSnapshotRepositoryProtocol
    private let permissionRepository: any CapturePermissionRepositoryProtocol

    init(
        lifecycleRepository: any CaptureLifecycleRepositoryProtocol,
        snapshotRepository: any CaptureSnapshotRepositoryProtocol,
        permissionRepository: any CapturePermissionRepositoryProtocol
    ) {
        self.lifecycleRepository = lifecycleRepository
        self.snapshotRepository = snapshotRepository
        self.permissionRepository = permissionRepository
    }

    func startCapture(windowID: UInt32, fps: Double) async throws {
        try await lifecycleRepository.startCapture(windowID: windowID, fps: fps)
    }

    func stopCapture(windowID: UInt32) async {
        await lifecycleRepository.stopCapture(windowID: windowID)
    }

    func updateFPS(windowID: UInt32, fps: Double) async throws {
        try await lifecycleRepository.updateFPS(windowID: windowID, fps: fps)
    }

    func capture(windowID: UInt32) -> CapturedImageRef? {
        snapshotRepository.captureWindow(windowID)
    }

    func captureOneShot(windowID: UInt32) async throws -> CapturedImageRef {
        try await snapshotRepository.captureWindowOneShot(windowID)
    }

    func ensureCaptureAccess() {
        permissionRepository.ensureCaptureAccess()
    }

    func observeFrames(windowID: UInt32) -> AsyncStream<CapturedImageRef> {
        lifecycleRepository.observeFrames(windowID: windowID)
    }
}
