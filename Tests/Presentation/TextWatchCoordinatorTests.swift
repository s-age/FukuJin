import XCTest
@testable import FukuJin

@MainActor
final class TextWatchCoordinatorTests: XCTestCase {
    private var sut: TextWatchCoordinator!
    private var mockExecuteAction: ExecuteTextWatchActionUseCaseMock!
    private var mockSendNotification: SendNotificationUseCaseMock!

    override func setUp() async throws {
        try await super.setUp()
        mockExecuteAction = ExecuteTextWatchActionUseCaseMock()
        mockSendNotification = SendNotificationUseCaseMock()
        sut = TextWatchCoordinator(
            scanText: ScanTextUseCaseStub(),
            executeAction: mockExecuteAction,
            captureWindowOneShot: CaptureWindowOneShotUseCaseStub(),
            sendNotification: mockSendNotification
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockExecuteAction = nil
        mockSendNotification = nil
        try await super.tearDown()
    }

    // MARK: - dispatchNotifications

    func test_dispatchNotifications_withNotificationRequested_sendsOneNotification() async {
        await sut.dispatchNotifications(events: [.notificationRequested], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executeCallCount, 1)
    }

    func test_dispatchNotifications_withNotificationRequested_usesFukuJinAsTitle() async {
        await sut.dispatchNotifications(events: [.notificationRequested], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executedRequests.first?.title, "FukuJin")
    }

    func test_dispatchNotifications_withNotificationRequested_formatsBodyWithMatchedText() async {
        await sut.dispatchNotifications(events: [.notificationRequested], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executedRequests.first?.body, "Found: needle")
    }

    func test_dispatchNotifications_withCommandFailed_sendsOneNotification() async {
        await sut.dispatchNotifications(
            events: [.commandFailed(.exitedWithNonZeroStatus(status: "boom"))],
            matchedText: "needle"
        )
        XCTAssertEqual(mockSendNotification.executeCallCount, 1)
    }

    func test_dispatchNotifications_withCommandFailed_usesFukuJinAsTitle() async {
        await sut.dispatchNotifications(
            events: [.commandFailed(.exitedWithNonZeroStatus(status: "boom"))],
            matchedText: "needle"
        )
        XCTAssertEqual(mockSendNotification.executedRequests.first?.title, "FukuJin")
    }

    func test_dispatchNotifications_withCommandFailed_sendsFormattedFailureAsBody() async {
        await sut.dispatchNotifications(
            events: [.commandFailed(.exitedWithNonZeroStatus(status: "boom"))],
            matchedText: "needle"
        )
        XCTAssertEqual(mockSendNotification.executedRequests.first?.body, "Command failed: boom")
    }

    func test_dispatchNotifications_withWindowActivated_doesNotSendNotification() async {
        await sut.dispatchNotifications(events: [.windowActivated], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executeCallCount, 0)
    }

    func test_dispatchNotifications_withCommandSucceeded_doesNotSendNotification() async {
        await sut.dispatchNotifications(events: [.commandSucceeded], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executeCallCount, 0)
    }

    func test_dispatchNotifications_withMixedEvents_sendsOnlyForNotifyingOnes() async {
        await sut.dispatchNotifications(
            events: [
                .notificationRequested,
                .windowActivated,
                .commandSucceeded,
                .commandFailed(.exitedWithNonZeroStatus(status: "boom"))
            ],
            matchedText: "needle"
        )
        XCTAssertEqual(mockSendNotification.executeCallCount, 2)
    }

    func test_dispatchNotifications_withEmptyEvents_doesNotSendNotification() async {
        await sut.dispatchNotifications(events: [], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executeCallCount, 0)
    }

    func test_dispatchNotifications_swallowsSendNotificationError() async {
        struct StubError: Error {}
        mockSendNotification.executeError = StubError()
        await sut.dispatchNotifications(events: [.notificationRequested], matchedText: "needle")
        XCTAssertEqual(mockSendNotification.executeCallCount, 1)
    }
}

// MARK: - Minimal stubs (unused by tests under exercise)

private final class ScanTextUseCaseStub: AsyncUseCase, @unchecked Sendable {
    func execute(_ request: ScanTextRequest) async throws -> ScanTextResponse {
        ScanTextResponse(matched: false, windowID: request.windowID, matchedBoundingBoxes: [])
    }
}

private final class CaptureWindowOneShotUseCaseStub: AsyncUseCase, @unchecked Sendable {
    func execute(_ request: CaptureWindowOneShotRequest) async throws -> CapturedImageRefResponse {
        throw CancellationError()
    }
}
