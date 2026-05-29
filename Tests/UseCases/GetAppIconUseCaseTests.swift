import XCTest
@testable import FukuJin

final class GetAppIconUseCaseTests: XCTestCase {
    private var sut: GetAppIconUseCase!
    private var mockService: AppIconDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = AppIconDomainServiceMock()
        sut = GetAppIconUseCase(appIconService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func test_execute_callsDomainServiceOnce() throws {
        _ = try sut.execute(GetAppIconRequest(bundleIdentifier: "com.example.app", localizedName: nil))
        XCTAssertEqual(mockService.appIconCallCount, 1)
    }

    func test_execute_forwardsBundleIdentifier() throws {
        _ = try sut.execute(GetAppIconRequest(bundleIdentifier: "com.example.app", localizedName: nil))
        XCTAssertEqual(mockService.lastBundleIdentifier, "com.example.app")
    }

    func test_execute_forwardsLocalizedName() throws {
        _ = try sut.execute(GetAppIconRequest(bundleIdentifier: nil, localizedName: "Example"))
        XCTAssertEqual(mockService.lastLocalizedName, "Example")
    }

    func test_execute_returnsResponseWhenServiceReturnsData() throws {
        let pngData = Data([0x89, 0x50, 0x4E, 0x47])
        mockService.stubbedAppIconData = pngData
        let response = try sut.execute(GetAppIconRequest(bundleIdentifier: nil, localizedName: "Example"))
        XCTAssertEqual(response, AppIconResponse(pngData: pngData))
    }

    func test_execute_returnsNilWhenServiceReturnsNil() throws {
        mockService.stubbedAppIconData = nil
        let response = try sut.execute(GetAppIconRequest(bundleIdentifier: nil, localizedName: "Example"))
        XCTAssertNil(response)
    }

    func test_validation_rejectsBothNil() {
        let request = GetAppIconRequest(bundleIdentifier: nil, localizedName: nil)
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.missingAppIdentifier = error else {
                return XCTFail("expected .missingAppIdentifier, got \(error)")
            }
        }
    }

    func test_validation_acceptsBundleIdentifierOnly() {
        let request = GetAppIconRequest(bundleIdentifier: "com.example.app", localizedName: nil)
        XCTAssertNoThrow(try request.validate())
    }

    func test_validation_acceptsLocalizedNameOnly() {
        let request = GetAppIconRequest(bundleIdentifier: nil, localizedName: "Example")
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_skipsExecuteWhenValidationFails() {
        let decorated = ValidationSyncUseCaseDecorator(decoratee: sut!)
        do {
            _ = try decorated.execute(GetAppIconRequest(bundleIdentifier: nil, localizedName: nil))
            XCTFail("Expected validation error")
        } catch {
            XCTAssertEqual(mockService.appIconCallCount, 0,
                           "domain service must not be called when validation fails")
        }
    }
}
