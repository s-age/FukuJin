import XCTest
@testable import FukuJin

final class UpdateFPSUseCaseTests: XCTestCase {
    private var mock: PinDomainServiceMock!
    private var sut: UpdateFPSUseCase!

    override func setUp() {
        super.setUp()
        mock = PinDomainServiceMock()
        mock.stubbedState = PinnedWindowList.empty.pinning(
            WindowInfo(id: 1, ownerPID: 1, ownerName: "App", windowName: "W1"),
            seed: .default
        )
        sut = UpdateFPSUseCase(pinService: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    private func fps(in response: PinnedWindowListResponse) -> Double? {
        response[1]?.fps
    }

    // MARK: - execute

    func test_execute_callsMutateWindowOnce() throws {
        _ = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 30))
        XCTAssertEqual(mock.mutateWindowCallCount, 1)
    }

    func test_execute_appliesFPS() throws {
        let response = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 30))
        XCTAssertEqual(fps(in: response), 30)
    }

    func test_execute_leavesOpacityUnchanged() throws {
        // default opacity is 0.5; fps update must not alter it
        let response = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 30))
        XCTAssertEqual(response[1]?.opacity, 0.5)
    }

    // clamping is enforced at the entity even when validation is bypassed
    func test_execute_clampsFPSAboveMaximum() throws {
        let response = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 1000))
        XCTAssertEqual(fps(in: response), 60)
    }

    func test_execute_clampsFPSBelowMinimum() throws {
        let response = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 0))
        XCTAssertEqual(fps(in: response), 1)
    }

    func test_execute_roundsFractionalFPS() throws {
        let response = try sut.execute(UpdateFPSRequest(windowID: 1, fps: 2.7))
        XCTAssertEqual(fps(in: response), 3)
    }

    func test_execute_throwsWindowNotFoundForUnknownID() {
        XCTAssertThrowsError(
            try sut.execute(UpdateFPSRequest(windowID: 99, fps: 30))
        ) { error in
            guard case DomainError.windowNotFound(let windowID) = error else {
                return XCTFail("expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(windowID, 99)
        }
    }

    // MARK: - validation

    func test_validation_rejectsZeroWindowID() {
        let request = UpdateFPSRequest(windowID: 0, fps: 30)
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidWindowID = error else {
                return XCTFail("expected .invalidWindowID, got \(error)")
            }
        }
    }

    func test_validation_rejectsFPSOutOfRange() {
        let request = UpdateFPSRequest(windowID: 1, fps: 1000)
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidFPS = error else {
                return XCTFail("expected .invalidFPS, got \(error)")
            }
        }
    }

    func test_validation_acceptsValidRequest() {
        let request = UpdateFPSRequest(windowID: 1, fps: 30)
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_skipsServiceWhenValidationFails() {
        let decorated = ValidationSyncUseCaseDecorator(decoratee: sut!)
        XCTAssertThrowsError(
            try decorated.execute(UpdateFPSRequest(windowID: 0, fps: 30))
        )
        XCTAssertEqual(mock.mutateWindowCallCount, 0,
                       "service must not be called when validation fails")
    }
}
