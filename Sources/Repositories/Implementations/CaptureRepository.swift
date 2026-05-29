import CoreGraphics

final class CaptureRepository:
    CaptureLifecycleRepositoryProtocol,
    CaptureSnapshotRepositoryProtocol,
    WindowBoundsRepositoryProtocol,
    CapturePermissionRepositoryProtocol,
    Sendable {
    private let dataSource: any CaptureDataSourceProtocol
    private let imageStore: any CapturedImageStoreProtocol

    init(
        dataSource: any CaptureDataSourceProtocol,
        imageStore: any CapturedImageStoreProtocol
    ) {
        self.dataSource = dataSource
        self.imageStore = imageStore
    }

    func startCapture(windowID: UInt32, fps: Double) async throws {
        do {
            try await dataSource.startCapture(windowID: windowID, fps: fps)
        } catch InfrastructureError.windowNotFound(let id) {
            throw DomainError.windowNotFound(windowID: id)
        }
    }

    func stopCapture(windowID: UInt32) async {
        imageStore.clearLatest(windowID: windowID)
        await dataSource.stopCapture(windowID: windowID)
    }

    func updateFPS(windowID: UInt32, fps: Double) async throws {
        try await dataSource.updateFPS(windowID: windowID, fps: fps)
    }

    func captureWindow(_ windowID: UInt32) -> CapturedImageRef? {
        guard let cgImage = dataSource.captureWindow(windowID),
              let bounds = dataSource.getWindowBounds(windowID)
        else { return nil }
        imageStore.storeLatest(cgImage, windowID: windowID)
        return CapturedImageRef(resolution: .streaming, windowID: windowID, bounds: BoundingBox(bounds))
    }

    func captureWindowOneShot(_ windowID: UInt32) async throws -> CapturedImageRef {
        do {
            let cgImage = try await dataSource.captureWindowOneShot(windowID)
            let bounds = dataSource.getWindowBounds(windowID).map(BoundingBox.init) ?? .zero
            let snapshotID = imageStore.store(cgImage)
            return CapturedImageRef(resolution: .oneShot(snapshotID: snapshotID), windowID: windowID, bounds: bounds)
        } catch InfrastructureError.windowNotFound(let id) {
            throw DomainError.windowNotFound(windowID: id)
        }
    }

    func getWindowBounds(_ windowID: UInt32) -> BoundingBox? {
        guard let rect = dataSource.getWindowBounds(windowID) else { return nil }
        return BoundingBox(rect)
    }

    func ensureCaptureAccess() {
        if !dataSource.preflightCaptureAccess() {
            dataSource.requestCaptureAccess()
        }
    }

    func observeFrames(windowID: UInt32) -> AsyncStream<CapturedImageRef> {
        let raw = dataSource.observeFrames(windowID: windowID)
        let dataSource = self.dataSource
        let imageStore = self.imageStore
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task {
                for await cgImage in raw {
                    let bounds = dataSource.getWindowBounds(windowID).map(BoundingBox.init) ?? .zero
                    imageStore.storeLatest(cgImage, windowID: windowID)
                    continuation.yield(CapturedImageRef(resolution: .streaming, windowID: windowID, bounds: bounds))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
