import XCTest
@testable import FukuJin

final class UpdateLaunchAtLoginUseCaseTests: XCTestCase {
    private var mock: LaunchAtLoginDomainServiceMock!
    private var sut: UpdateLaunchAtLoginUseCase!

    override func setUp() {
        super.setUp()
        mock = LaunchAtLoginDomainServiceMock()
        sut = UpdateLaunchAtLoginUseCase(launchAtLoginService: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    // MARK: - execute

    func test_execute_callsSetEnabledOnce() throws {
        _ = try sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertEqual(mock.setEnabledCallCount, 1)
    }

    func test_execute_forwardsEnabledTrue() throws {
        _ = try sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertEqual(mock.lastSetEnabledArg, true)
    }

    func test_execute_forwardsEnabledFalse() throws {
        _ = try sut.execute(UpdateLaunchAtLoginRequest(enabled: false))
        XCTAssertEqual(mock.lastSetEnabledArg, false)
    }

    func test_execute_returnsServiceIsEnabledState() throws {
        mock.stubbedIsEnabled = true
        let result = try sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertTrue(result)
    }

    func test_execute_returnsActualStateNotRequestedState() throws {
        // request asks to enable, but the OS reports it stayed disabled;
        // the use case must report isEnabled(), not request.enabled
        mock.stubbedIsEnabled = false
        let result = try sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertFalse(result)
    }

    func test_execute_queriesIsEnabledAfterSet() throws {
        _ = try sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertEqual(mock.isEnabledCallCount, 1)
    }

    func test_execute_propagatesSetEnabledError() {
        struct RegistrationError: Error {}
        mock.setEnabledError = RegistrationError()
        XCTAssertThrowsError(try sut.execute(UpdateLaunchAtLoginRequest(enabled: true)))
    }

    func test_execute_doesNotQueryIsEnabledWhenSetThrows() {
        struct RegistrationError: Error {}
        mock.setEnabledError = RegistrationError()
        _ = try? sut.execute(UpdateLaunchAtLoginRequest(enabled: true))
        XCTAssertEqual(mock.isEnabledCallCount, 0,
                       "isEnabled() must not run after setEnabled() throws")
    }
}
