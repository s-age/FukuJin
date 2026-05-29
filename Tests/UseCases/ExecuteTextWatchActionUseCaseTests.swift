import XCTest
@testable import FukuJin

final class ExecuteTextWatchActionUseCaseTests: XCTestCase {
    private var sut: ExecuteTextWatchActionUseCase!
    private var mockService: TextWatchDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = TextWatchDomainServiceMock()
        sut = ExecuteTextWatchActionUseCase(textWatchService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - execute

    func test_execute_callsDomainServiceOnce() async throws {
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 100,
            actions: [.notification]
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(mockService.executeActionsCallCount, 1)
    }

    func test_execute_forwardsWindowID() async throws {
        let request = ExecuteTextWatchActionRequest(
            windowID: 77,
            pid: 100,
            actions: [.notification]
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(mockService.lastWindowID, 77)
    }

    func test_execute_forwardsPID() async throws {
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 555,
            actions: [.notification]
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(mockService.lastPID, 555)
    }

    func test_execute_mapsActionDTOsToDomain() async throws {
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 100,
            actions: [.notification, .activateWindow, .command("ls")]
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(mockService.lastActions, [.notification, .activateWindow, .command(try WatchCommand("ls"))])
    }

    func test_execute_returnsResponseWithMappedEvents() async throws {
        mockService.stubbedEvents = [.notificationRequested, .commandSucceeded]
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 100,
            actions: [.notification, .command("ls")]
        )
        let response = try await sut.execute(request)
        XCTAssertEqual(response.events, [.notificationRequested, .commandSucceeded])
    }

    func test_execute_mapsCommandFailure() async throws {
        mockService.stubbedEvents = [.commandFailed(.exitedWithNonZeroStatus(status: "boom"))]
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 100,
            actions: [.command("bad")]
        )
        let response = try await sut.execute(request)
        XCTAssertEqual(response.events, [.commandFailed(.exitedWithNonZeroStatus(status: "boom"))])
    }

    func test_execute_returnsEmptyResponse_whenServiceReturnsNoEvents() async throws {
        mockService.stubbedEvents = []
        let request = ExecuteTextWatchActionRequest(
            windowID: 1,
            pid: 100,
            actions: [.notification]
        )
        let response = try await sut.execute(request)
        XCTAssertEqual(response.events, [])
    }

    // MARK: - validate

    func test_validate_rejectsEmptyActions() {
        let request = ExecuteTextWatchActionRequest(windowID: 1, pid: 100, actions: [])
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.emptyActionList = error else {
                return XCTFail("expected .emptyActionList, got \(error)")
            }
        }
    }

    func test_validate_acceptsNonEmptyActions() {
        let request = ExecuteTextWatchActionRequest(windowID: 1, pid: 100, actions: [.notification])
        XCTAssertNoThrow(try request.validate())
    }
}
