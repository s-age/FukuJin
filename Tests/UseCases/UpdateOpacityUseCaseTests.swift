import XCTest
@testable import FukuJin

final class UpdateOpacityUseCaseTests: XCTestCase {
    private var mock: PinDomainServiceMock!
    private var sut: UpdateOpacityUseCase!

    override func setUp() {
        super.setUp()
        mock = PinDomainServiceMock()
        mock.stubbedState = PinnedWindowList.empty.pinning(
            WindowInfo(id: 1, ownerPID: 1, ownerName: "App", windowName: "W1"),
            seed: .default
        )
        sut = UpdateOpacityUseCase(pinService: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    private func opacity(in response: PinnedWindowListResponse) -> Double? {
        response[1]?.opacity
    }

    // MARK: - execute

    func test_execute_callsMutateWindowOnce() throws {
        _ = try sut.execute(UpdateOpacityRequest(windowID: 1, opacity: 0.8))
        XCTAssertEqual(mock.mutateWindowCallCount, 1)
    }

    func test_execute_appliesOpacity() throws {
        let response = try sut.execute(UpdateOpacityRequest(windowID: 1, opacity: 0.8))
        XCTAssertEqual(opacity(in: response), 0.8)
    }

    func test_execute_leavesFPSUnchanged() throws {
        // default fps is 1.0; opacity update must not alter it
        let response = try sut.execute(UpdateOpacityRequest(windowID: 1, opacity: 0.8))
        XCTAssertEqual(response[1]?.fps, 1.0)
    }

    // clamping is enforced at the entity even when validation is bypassed
    func test_execute_clampsOpacityBelowMinimum() throws {
        let response = try sut.execute(UpdateOpacityRequest(windowID: 1, opacity: 0.0))
        XCTAssertEqual(opacity(in: response), 0.1)
    }

    func test_execute_clampsOpacityAboveMaximum() throws {
        let response = try sut.execute(UpdateOpacityRequest(windowID: 1, opacity: 5.0))
        XCTAssertEqual(opacity(in: response), 1.0)
    }

    func test_execute_throwsWindowNotFoundForUnknownID() {
        XCTAssertThrowsError(
            try sut.execute(UpdateOpacityRequest(windowID: 99, opacity: 0.8))
        ) { error in
            guard case DomainError.windowNotFound(let windowID) = error else {
                return XCTFail("expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(windowID, 99)
        }
    }

    // MARK: - validation

    func test_validation_rejectsZeroWindowID() {
        let request = UpdateOpacityRequest(windowID: 0, opacity: 0.5)
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidWindowID = error else {
                return XCTFail("expected .invalidWindowID, got \(error)")
            }
        }
    }

    func test_validation_rejectsOpacityOutOfRange() {
        let request = UpdateOpacityRequest(windowID: 1, opacity: 0.0)
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidOpacity = error else {
                return XCTFail("expected .invalidOpacity, got \(error)")
            }
        }
    }

    func test_validation_acceptsValidRequest() {
        let request = UpdateOpacityRequest(windowID: 1, opacity: 0.5)
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_skipsServiceWhenValidationFails() {
        let decorated = ValidationSyncUseCaseDecorator(decoratee: sut!)
        XCTAssertThrowsError(
            try decorated.execute(UpdateOpacityRequest(windowID: 0, opacity: 0.5))
        )
        XCTAssertEqual(mock.mutateWindowCallCount, 0,
                       "service must not be called when validation fails")
    }
}
