import XCTest
@testable import FukuJin

final class UpdateScanConfigUseCaseTests: XCTestCase {
    private var mock: PinDomainServiceMock!
    private var sut: UpdateScanConfigUseCase!

    override func setUp() {
        super.setUp()
        mock = PinDomainServiceMock()
        mock.stubbedState = PinnedWindowList.empty.pinning(
            WindowInfo(id: 1, ownerPID: 1, ownerName: "App", windowName: "W1"),
            seed: .default
        )
        sut = UpdateScanConfigUseCase(pinService: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    private func scanConfig(in response: PinnedWindowListResponse) -> ScanConfigResponse? {
        response[1]?.scan
    }

    private func request(
        searchText: String? = nil,
        actions: [TextWatchActionDTO]? = nil,
        isScanning: Bool? = nil
    ) -> UpdateScanConfigRequest {
        UpdateScanConfigRequest(
            windowID: 1, searchText: searchText, actions: actions, isScanning: isScanning
        )
    }

    // MARK: - execute

    func test_execute_callsMutateWindowOnce() throws {
        _ = try sut.execute(request(searchText: "needle"))
        XCTAssertEqual(mock.mutateWindowCallCount, 1)
    }

    func test_execute_appliesSearchText() throws {
        let response = try sut.execute(request(searchText: "needle"))
        XCTAssertEqual(scanConfig(in: response)?.searchText, "needle")
    }

    func test_execute_appliesIsScanning() throws {
        let response = try sut.execute(request(isScanning: true))
        XCTAssertEqual(scanConfig(in: response)?.isScanning, true)
    }

    func test_execute_appliesActionsMappedToDomain() throws {
        let response = try sut.execute(
            request(actions: [.notification, .command("echo hi")])
        )
        XCTAssertEqual(scanConfig(in: response)?.actions, [.notification, .command("echo hi")])
    }

    func test_execute_preservesUnspecifiedFields() throws {
        mock.stubbedState = try mock.stubbedState.mutatingWindow(1) { window in
            var updated = window
            updated.scan = .default.applying(searchText: "keep").applying(isScanning: true)
            return updated
        }
        // only actions are supplied; searchText and isScanning must survive
        let response = try sut.execute(request(actions: [.activateWindow]))
        XCTAssertEqual(scanConfig(in: response)?.searchText, "keep")
        XCTAssertEqual(scanConfig(in: response)?.isScanning, true)
    }

    func test_execute_propagatesInvalidCommandError() {
        XCTAssertThrowsError(
            try sut.execute(request(actions: [.command("bad\ncommand")]))
        ) { error in
            guard case ValidationError.invalidCommandString = error else {
                return XCTFail("expected .invalidCommandString, got \(error)")
            }
        }
    }

    func test_execute_throwsWindowNotFoundForUnknownID() {
        XCTAssertThrowsError(
            try sut.execute(
                UpdateScanConfigRequest(
                    windowID: 99, searchText: "x", actions: nil, isScanning: nil
                )
            )
        ) { error in
            guard case DomainError.windowNotFound(let windowID) = error else {
                return XCTFail("expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(windowID, 99)
        }
    }

    // MARK: - validation

    func test_validation_rejectsZeroWindowID() {
        let request = UpdateScanConfigRequest(
            windowID: 0, searchText: nil, actions: nil, isScanning: nil
        )
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidWindowID = error else {
                return XCTFail("expected .invalidWindowID, got \(error)")
            }
        }
    }

    func test_validation_rejectsSearchTextTooLong() {
        let request = request(searchText: String(repeating: "a", count: 257))
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.searchTextTooLong = error else {
                return XCTFail("expected .searchTextTooLong, got \(error)")
            }
        }
    }

    func test_validation_rejectsTooManyActions() {
        let request = request(actions: Array(repeating: .notification, count: 17))
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.tooManyActions = error else {
                return XCTFail("expected .tooManyActions, got \(error)")
            }
        }
    }

    func test_validation_rejectsInvalidCommandAction() {
        let request = request(actions: [.command("bad\ncommand")])
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidCommandString = error else {
                return XCTFail("expected .invalidCommandString, got \(error)")
            }
        }
    }

    func test_validation_acceptsValidConfig() {
        let request = request(searchText: "needle", actions: [.notification], isScanning: true)
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_skipsServiceWhenValidationFails() {
        let decorated = ValidationSyncUseCaseDecorator(decoratee: sut!)
        let request = UpdateScanConfigRequest(
            windowID: 0, searchText: nil, actions: nil, isScanning: nil
        )
        XCTAssertThrowsError(try decorated.execute(request))
        XCTAssertEqual(mock.mutateWindowCallCount, 0,
                       "service must not be called when validation fails")
    }
}
