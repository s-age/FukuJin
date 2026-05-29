import Foundation

@MainActor
final class TextWatchCoordinator {
    private var scanTimer: Timer?
    private let scanText: ScanTextUseCaseProtocol
    private let executeAction: ExecuteTextWatchActionUseCaseProtocol
    private let captureWindowOneShot: CaptureWindowOneShotUseCaseProtocol
    private let sendNotification: SendNotificationUseCaseProtocol

    var onHighlightsChanged: ((_ windowID: UInt32, _ boundingBoxes: [BoundingBoxResponse]) -> Void)?
    var onMatchDetected: ((_ windowID: UInt32) -> Void)?

    init(
        scanText: ScanTextUseCaseProtocol,
        executeAction: ExecuteTextWatchActionUseCaseProtocol,
        captureWindowOneShot: CaptureWindowOneShotUseCaseProtocol,
        sendNotification: SendNotificationUseCaseProtocol
    ) {
        self.scanText = scanText
        self.executeAction = executeAction
        self.captureWindowOneShot = captureWindowOneShot
        self.sendNotification = sendNotification
    }

    func start(
        pinnedWindowsProvider: @escaping @MainActor () -> PinnedWindowListResponse
    ) {
        stop()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.scanAllWindows(
                    pinnedWindows: pinnedWindowsProvider(),
                    pinnedWindowsProvider: pinnedWindowsProvider
                )
            }
        }
    }

    func stop() {
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func scanAllWindows(
        pinnedWindows: PinnedWindowListResponse,
        pinnedWindowsProvider: @MainActor () -> PinnedWindowListResponse
    ) async {
        for entry in pinnedWindows.windows {
            await scanAndAct(
                entry,
                isStillScanning: { pinnedWindowsProvider()[entry.windowID]?.scan.isScanning == true }
            )
        }
    }

    /// Capture → scan → (only if still scanning) act, for a single pinned window.
    ///
    /// `isStillScanning` is re-evaluated *after* the async scan completes: the user may have
    /// paused the watcher while the capture/scan was in flight, in which case acting on the
    /// now-stale match would be wrong. Deciding whether to continue the async pipeline on fresh
    /// state is the coordinator's concern, so the guard stays here rather than in a use case.
    private func scanAndAct(
        _ entry: PinnedWindowResponse,
        isStillScanning: @MainActor () -> Bool
    ) async {
        guard entry.scan.isCapturing else {
            clearHighlights(entry.windowID)
            return
        }

        guard let capturedImage = try? await captureWindowOneShot.execute(
            CaptureWindowOneShotRequest(windowID: entry.windowID)
        ), let request = makeScanRequest(
            windowID: entry.windowID,
            image: capturedImage,
            searchText: entry.scan.searchText
        ) else { return }

        guard let result = try? await scanText.execute(request), result.matched else {
            clearHighlights(entry.windowID)
            return
        }

        guard isStillScanning() else {
            clearHighlights(entry.windowID)
            return
        }

        onHighlightsChanged?(entry.windowID, result.matchedBoundingBoxes)
        onMatchDetected?(entry.windowID)
        await runActions(for: entry)
    }

    private func runActions(for entry: PinnedWindowResponse) async {
        let actionDTOs = entry.scan.actions.map { response -> TextWatchActionDTO in
            switch response {
            case .notification: .notification
            case .activateWindow: .activateWindow
            case .command(let cmd): .command(cmd)
            }
        }

        let actionRequest = ExecuteTextWatchActionRequest(
            windowID: entry.windowID,
            pid: entry.ownerPID,
            actions: actionDTOs
        )

        guard let response = try? await executeAction.execute(actionRequest) else { return }
        await dispatchNotifications(events: response.events, matchedText: entry.scan.searchText)
    }

    private func clearHighlights(_ windowID: UInt32) {
        onHighlightsChanged?(windowID, [])
    }

    private func makeScanRequest(
        windowID: UInt32,
        image: CapturedImageRefResponse,
        searchText: String
    ) -> ScanTextRequest? {
        // One-shot captures always carry a snapshot token; streaming frames (snapshotID == nil)
        // are not scanned.
        guard let imageID = image.snapshotID else { return nil }
        return ScanTextRequest(
            windowID: windowID,
            imageID: imageID,
            bounds: ScanTextRequest.Bounds(
                x: image.bounds.x,
                y: image.bounds.y,
                width: image.bounds.width,
                height: image.bounds.height
            ),
            searchText: searchText
        )
    }

    func dispatchNotifications(
        events: [TextWatchActionEventResponse],
        matchedText: String
    ) async {
        for event in events {
            switch event {
            case .notificationRequested:
                _ = try? await sendNotification.execute(
                    SendNotificationRequest(
                        title: Self.notificationTitle,
                        body: "Found: \(matchedText)"
                    )
                )
            case .commandFailed(let failure):
                _ = try? await sendNotification.execute(
                    SendNotificationRequest(
                        title: Self.notificationTitle,
                        body: failure.displayMessage
                    )
                )
            case .windowActivated, .commandSucceeded:
                break
            }
        }
    }

    private static let notificationTitle = "FukuJin"
}
