import XCTest
@testable import FukuJin

final class AppIconDomainServiceTests: XCTestCase {
    private var sut: AppIconDomainService!
    private var mockRepository: WorkspaceRepositoryMock!

    override func setUp() {
        super.setUp()
        mockRepository = WorkspaceRepositoryMock()
        sut = AppIconDomainService(appIconRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_appIcon_callsRepositoryOnce() {
        _ = sut.appIcon(bundleIdentifier: "com.example.app", localizedName: nil)
        XCTAssertEqual(mockRepository.appIconCallCount, 1)
    }

    func test_appIcon_forwardsBundleIdentifier() {
        _ = sut.appIcon(bundleIdentifier: "com.example.app", localizedName: nil)
        XCTAssertEqual(mockRepository.lastBundleIdentifier, "com.example.app")
    }

    func test_appIcon_forwardsLocalizedName() {
        _ = sut.appIcon(bundleIdentifier: nil, localizedName: "Example")
        XCTAssertEqual(mockRepository.lastLocalizedName, "Example")
    }

    func test_appIcon_returnsRepositoryResult() {
        let expected = Data([0x89, 0x50, 0x4E, 0x47])
        mockRepository.stubbedAppIconData = expected
        XCTAssertEqual(sut.appIcon(bundleIdentifier: nil, localizedName: "Example"), expected)
    }

    func test_appIcon_returnsNilWhenRepositoryReturnsNil() {
        mockRepository.stubbedAppIconData = nil
        XCTAssertNil(sut.appIcon(bundleIdentifier: nil, localizedName: "Example"))
    }
}
