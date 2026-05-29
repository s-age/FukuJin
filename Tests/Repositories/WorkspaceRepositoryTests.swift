import XCTest
@testable import FukuJin

final class WorkspaceRepositoryTests: XCTestCase {
    private var sut: WorkspaceRepository!
    private var mockDataSource: WorkspaceDataSourceMock!

    override func setUp() {
        super.setUp()
        mockDataSource = WorkspaceDataSourceMock()
        sut = WorkspaceRepository(dataSource: mockDataSource)
    }

    override func tearDown() {
        sut = nil
        mockDataSource = nil
        super.tearDown()
    }

    func test_appIcon_callsDataSourceOnce() {
        _ = sut.appIcon(for: "com.example.app", localizedName: nil)
        XCTAssertEqual(mockDataSource.appIconCallCount, 1)
    }

    func test_appIcon_forwardsBundleIdentifier() {
        _ = sut.appIcon(for: "com.example.app", localizedName: nil)
        XCTAssertEqual(mockDataSource.lastBundleIdentifier, "com.example.app")
    }

    func test_appIcon_forwardsLocalizedName() {
        _ = sut.appIcon(for: nil, localizedName: "Example")
        XCTAssertEqual(mockDataSource.lastLocalizedName, "Example")
    }

    func test_appIcon_returnsDataSourceResult() {
        let expected = Data([0x89, 0x50, 0x4E, 0x47])
        mockDataSource.stubbedAppIconData = expected
        XCTAssertEqual(sut.appIcon(for: nil, localizedName: "Example"), expected)
    }

    func test_appIcon_returnsNilWhenDataSourceReturnsNil() {
        mockDataSource.stubbedAppIconData = nil
        XCTAssertNil(sut.appIcon(for: nil, localizedName: "Example"))
    }
}
