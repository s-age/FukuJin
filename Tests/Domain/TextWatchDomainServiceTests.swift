import XCTest
@testable import FukuJin

final class TextWatchDomainServiceTests: XCTestCase {
    private var sut: TextWatchDomainService!
    private var mockTextRecognition: TextRecognitionRepositoryMock!
    private var mockCommand: CommandRepositoryMock!
    private var mockWindowAction: WindowActionDomainServiceMock!
    private var stubSettings: TextWatchSettingsRepositoryStub!

    override func setUp() {
        super.setUp()
        mockTextRecognition = TextRecognitionRepositoryMock()
        mockCommand = CommandRepositoryMock()
        mockWindowAction = WindowActionDomainServiceMock()
        stubSettings = TextWatchSettingsRepositoryStub()
        sut = TextWatchDomainService(
            textRecognitionRepository: mockTextRecognition,
            commandRepository: mockCommand,
            windowActionService: mockWindowAction,
            settingsRepository: stubSettings
        )
    }

    override func tearDown() {
        sut = nil
        mockTextRecognition = nil
        mockCommand = nil
        mockWindowAction = nil
        stubSettings = nil
        super.tearDown()
    }

    // MARK: - scanAndMatch

    private func makeImage() -> CapturedImageRef {
        CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: BoundingBox(x: 0, y: 0, width: 10, height: 10))
    }

    private func makeConfig(searchText: String) -> ScanConfig {
        ScanConfig.default.applying(searchText: searchText).applying(isScanning: true)
    }

    func test_scanAndMatch_withEmptySearch_returnsUnmatched() async throws {
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: ""))
        XCTAssertFalse(result.matched)
    }

    func test_scanAndMatch_withEmptySearch_returnsEmptyBoundingBoxes() async throws {
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: ""))
        XCTAssertTrue(result.matchedBoundingBoxes.isEmpty)
    }

    func test_scanAndMatch_withEmptySearch_doesNotCallRecognition() async throws {
        _ = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: ""))
        XCTAssertEqual(mockTextRecognition.recognizeTextCallCount, 0)
    }

    func test_scanAndMatch_delegatesToRecognitionRepository_withCapturedImage() async throws {
        let image = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: BoundingBox(x: 1, y: 2, width: 3, height: 4))
        _ = try await sut.scanAndMatch(image: image, config: makeConfig(searchText: "needle"))
        XCTAssertEqual(mockTextRecognition.lastRecognizedImage, image)
    }

    func test_scanAndMatch_returnsMatched_whenAnyBlockContainsSearch() async throws {
        let box = BoundingBox(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        mockTextRecognition.stubbedBlocks = [
            RecognizedTextBlock(text: "Found needle here", boundingBox: box)
        ]
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: "needle"))
        XCTAssertTrue(result.matched)
    }

    func test_scanAndMatch_returnsBoundingBoxesForMatchedBlocks() async throws {
        let box = BoundingBox(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        mockTextRecognition.stubbedBlocks = [
            RecognizedTextBlock(text: "Found needle here", boundingBox: box)
        ]
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: "needle"))
        XCTAssertEqual(result.matchedBoundingBoxes, [box])
    }

    func test_scanAndMatch_returnsUnmatched_whenNoBlockMatches() async throws {
        mockTextRecognition.stubbedBlocks = [
            RecognizedTextBlock(text: "haystack", boundingBox: .zero)
        ]
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: "needle"))
        XCTAssertFalse(result.matched)
    }

    func test_scanAndMatch_isCaseInsensitive() async throws {
        mockTextRecognition.stubbedBlocks = [
            RecognizedTextBlock(text: "Found NEEDLE here", boundingBox: .zero)
        ]
        let result = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: "needle"))
        XCTAssertTrue(result.matched)
    }

    // MARK: - executeActions

    func test_executeActions_withNotificationAction_returnsNotificationRequestedEvent() async {
        let events = await sut.executeActions([.notification], windowID: 1, pid: 100)
        XCTAssertEqual(events, [.notificationRequested])
    }

    func test_executeActions_withActivateWindowAction_callsRaiseWindowOnce() async {
        _ = await sut.executeActions([.activateWindow], windowID: 42, pid: 99)
        XCTAssertEqual(mockWindowAction.raiseWindowCallCount, 1)
    }

    func test_executeActions_withActivateWindowAction_forwardsWindowID() async {
        _ = await sut.executeActions([.activateWindow], windowID: 42, pid: 99)
        XCTAssertEqual(mockWindowAction.lastRaiseWindowID, 42)
    }

    func test_executeActions_withActivateWindowAction_forwardsPID() async {
        _ = await sut.executeActions([.activateWindow], windowID: 42, pid: 99)
        XCTAssertEqual(mockWindowAction.lastRaisePID, 99)
    }

    func test_executeActions_withActivateWindowAction_returnsWindowActivatedEvent() async {
        let events = await sut.executeActions([.activateWindow], windowID: 1, pid: 100)
        XCTAssertEqual(events, [.windowActivated])
    }

    func test_executeActions_withCommandAction_success_callsExecuteOnce() async throws {
        _ = await sut.executeActions([.command(try WatchCommand("echo hi"))], windowID: 1, pid: 100)
        XCTAssertEqual(mockCommand.executeCallCount, 1)
    }

    func test_executeActions_withCommandAction_success_forwardsCommand() async throws {
        _ = await sut.executeActions([.command(try WatchCommand("echo hi"))], windowID: 1, pid: 100)
        XCTAssertEqual(mockCommand.lastCommand, "echo hi")
    }

    func test_executeActions_withCommandAction_success_returnsCommandSucceededEvent() async throws {
        let events = await sut.executeActions([.command(try WatchCommand("echo hi"))], windowID: 1, pid: 100)
        XCTAssertEqual(events, [.commandSucceeded])
    }

    func test_executeActions_withCommandAction_genericFailure_returnsExecutionFailed() async throws {
        struct StubError: LocalizedError {
            var errorDescription: String? { "stub failure" }
        }
        mockCommand.executeError = StubError()
        let events = await sut.executeActions([.command(try WatchCommand("bad cmd"))], windowID: 1, pid: 100)
        XCTAssertEqual(events, [.commandFailed(.executionFailed)])
    }

    func test_executeActions_withCommandAction_nonZeroExit_returnsStatusFailure() async throws {
        mockCommand.executeError = DomainError.commandExitedWithNonZeroStatus(message: "exit 1")
        let events = await sut.executeActions([.command(try WatchCommand("bad cmd"))], windowID: 1, pid: 100)
        XCTAssertEqual(events, [.commandFailed(.exitedWithNonZeroStatus(status: "exit 1"))])
    }

    func test_executeActions_withMultipleActions_returnsEventsInOrder() async throws {
        let events = await sut.executeActions(
            [.notification, .activateWindow, .command(try WatchCommand("echo"))],
            windowID: 1,
            pid: 100
        )
        XCTAssertEqual(events, [.notificationRequested, .windowActivated, .commandSucceeded])
    }

    func test_executeActions_withEmptyActions_returnsNoEvents() async {
        let events = await sut.executeActions([], windowID: 1, pid: 100)
        XCTAssertEqual(events, [])
    }

    func test_scanAndMatch_passesConfiguredLanguagesToRecognition() async throws {
        stubSettings.storedLanguages = [.japanese, .korean]
        _ = try await sut.scanAndMatch(image: makeImage(), config: makeConfig(searchText: "needle"))
        XCTAssertEqual(mockTextRecognition.lastRecognizedLanguages, [.japanese, .korean])
    }
}

private final class TextWatchSettingsRepositoryStub: SettingsRepositoryProtocol, @unchecked Sendable {
    var storedConfig: OverlayConfig = .default
    var storedLanguages: [OCRLanguage] = OCRLanguage.default
    func loadDefaultConfig() -> OverlayConfig { storedConfig }
    func saveDefaultConfig(_ config: OverlayConfig) {}
    func loadRecognitionLanguages() -> [OCRLanguage] { storedLanguages }
    func saveRecognitionLanguages(_ languages: [OCRLanguage]) { storedLanguages = languages }
}
