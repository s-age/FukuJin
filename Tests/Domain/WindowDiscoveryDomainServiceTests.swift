import XCTest
@testable import FukuJin

final class WindowDiscoveryDomainServiceTests: XCTestCase {
    private var mockRepository: WindowRepositoryMock!
    private var sut: WindowDiscoveryDomainService!

    override func setUp() {
        super.setUp()
        mockRepository = WindowRepositoryMock()
        sut = WindowDiscoveryDomainService(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    private func window(id: UInt32, pid: Int32 = 1, name: String = "App") -> WindowInfo {
        WindowInfo(id: id, ownerPID: pid, ownerName: name, windowName: name)
    }

    // MARK: - frontmostWindowID(ownedBy:)

    func test_frontmostWindowID_returnsTopmostWindowOfOwningApp() {
        mockRepository.stubbedWindows = [
            window(id: 10, pid: 1),
            window(id: 20, pid: 2),
            window(id: 30, pid: 1)
        ]
        XCTAssertEqual(sut.frontmostWindowID(ownedBy: 1), 10)
    }

    func test_frontmostWindowID_skipsWindowsOfOtherApps_preservingZOrder() {
        // A window of another app sits in front; the owning app's topmost window is still 20.
        mockRepository.stubbedWindows = [
            window(id: 5, pid: 99),
            window(id: 20, pid: 1),
            window(id: 21, pid: 1)
        ]
        XCTAssertEqual(sut.frontmostWindowID(ownedBy: 1), 20)
    }

    func test_frontmostWindowID_returnsNil_whenAppHasNoVisibleWindow() {
        mockRepository.stubbedWindows = [window(id: 5, pid: 99)]
        XCTAssertNil(sut.frontmostWindowID(ownedBy: 1))
    }

    func test_frontmostWindowID_returnsNil_whenNoWindows() {
        mockRepository.stubbedWindows = []
        XCTAssertNil(sut.frontmostWindowID(ownedBy: 1))
    }
}
