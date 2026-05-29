import XCTest
@testable import FukuJin

final class GetFrontmostWindowUseCaseTests: XCTestCase {
    private var mock: WindowDiscoveryDomainServiceMock!
    private var sut: GetFrontmostWindowUseCase!

    override func setUp() {
        super.setUp()
        mock = WindowDiscoveryDomainServiceMock()
        sut = GetFrontmostWindowUseCase(discoveryService: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    // MARK: - execute

    func test_execute_callsFrontmostWindowIDOnce() throws {
        _ = try sut.execute(GetFrontmostWindowRequest(ownerPID: 1))
        XCTAssertEqual(mock.frontmostWindowIDCallCount, 1)
    }

    func test_execute_forwardsOwnerPID() throws {
        _ = try sut.execute(GetFrontmostWindowRequest(ownerPID: 4242))
        XCTAssertEqual(mock.lastFrontmostOwnerPID, 4242)
    }

    func test_execute_returnsServiceWindowID() throws {
        mock.stubbedFrontmostWindowID = 42
        XCTAssertEqual(try sut.execute(GetFrontmostWindowRequest(ownerPID: 1)), 42)
    }

    func test_execute_returnsNil_whenServiceReturnsNil() throws {
        mock.stubbedFrontmostWindowID = nil
        XCTAssertNil(try sut.execute(GetFrontmostWindowRequest(ownerPID: 1)))
    }
}
