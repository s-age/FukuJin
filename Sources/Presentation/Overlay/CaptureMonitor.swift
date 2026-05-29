import AppKit

@MainActor
final class CaptureMonitor {
    enum State {
        case idle
        case starting
        case monitoring
    }

    private(set) var state: State = .idle
    private(set) var fps: Double
    private var consumerTask: Task<Void, Never>?
    private let windowID: UInt32
    private let manageCaptureStream: ManageCaptureStreamUseCaseProtocol
    private let captureWindow: CaptureWindowUseCaseProtocol
    private let observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol

    var onFrameCaptured: ((CaptureResponse) -> Void)?
    var onTargetLost: (() -> Void)?

    init(
        windowID: UInt32,
        fps: Double,
        manageCaptureStream: ManageCaptureStreamUseCaseProtocol,
        captureWindow: CaptureWindowUseCaseProtocol,
        observeCaptureFrames: ObserveCaptureFramesUseCaseProtocol
    ) {
        self.windowID = windowID
        self.fps = fps
        self.manageCaptureStream = manageCaptureStream
        self.captureWindow = captureWindow
        self.observeCaptureFrames = observeCaptureFrames
    }

    func start() async {
        guard state == .idle else { return }
        state = .starting

        do {
            try await manageCaptureStream.execute(
                ManageCaptureStreamRequest(windowID: windowID, action: .start(fps: fps))
            )
        } catch {
            state = .idle
            return
        }

        guard state == .starting else { return }

        if let frame = try? captureWindow.execute(CaptureWindowRequest(windowID: windowID)) {
            onFrameCaptured?(frame)
        }

        guard state == .starting else { return }

        state = .monitoring
        startConsumer()
    }

    func updateFPS(_ newFPS: Double) {
        fps = newFPS
        guard state == .monitoring else { return }
        Task {
            try? await manageCaptureStream.execute(
                ManageCaptureStreamRequest(windowID: windowID, action: .updateFPS(newFPS))
            )
        }
    }

    func teardown() {
        state = .idle
        consumerTask?.cancel()
        consumerTask = nil
        Task {
            try? await manageCaptureStream.execute(
                ManageCaptureStreamRequest(windowID: windowID, action: .stop)
            )
        }
    }

    private func startConsumer() {
        guard let stream = try? observeCaptureFrames.execute(
            ObserveCaptureFramesRequest(windowID: windowID)
        ) else {
            handleStreamTermination()
            return
        }

        consumerTask = Task { @MainActor [weak self] in
            for await frame in stream {
                guard let self, self.state == .monitoring else { return }
                self.onFrameCaptured?(frame)
            }
            self?.handleStreamTermination()
        }
    }

    private func handleStreamTermination() {
        guard state == .monitoring else { return }
        teardown()
        onTargetLost?()
    }
}
