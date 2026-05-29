import XCTest
@testable import FukuJin

final class CommandRepositoryTests: XCTestCase {
    private var sut: CommandRepository!
    private var mockDataSource: CommandDataSourceMock!

    override func setUp() {
        super.setUp()
        mockDataSource = CommandDataSourceMock()
        sut = CommandRepository(dataSource: mockDataSource)
    }

    override func tearDown() {
        sut = nil
        mockDataSource = nil
        super.tearDown()
    }

    func test_execute_callsDataSourceOnce() async throws {
        try await sut.execute(try WatchCommand("/usr/bin/true"))
        XCTAssertEqual(mockDataSource.executeCallCount, 1)
    }

    func test_execute_forwardsCommandString() async throws {
        try await sut.execute(try WatchCommand("/usr/bin/true"))
        XCTAssertEqual(mockDataSource.lastExecutedCommand, "/usr/bin/true")
    }

    func test_execute_mapsProcessExitedNonZeroToCommandExitedWithNonZeroStatus() async throws {
        mockDataSource.executeError = InfrastructureError.processExitedNonZero(status: "exit 1")
        do {
            try await sut.execute(try WatchCommand("/usr/bin/false"))
            XCTFail("Expected DomainError.commandExitedWithNonZeroStatus")
        } catch let error as DomainError {
            guard case .commandExitedWithNonZeroStatus(let message) = error else {
                return XCTFail("Expected .commandExitedWithNonZeroStatus, got \(error)")
            }
            XCTAssertEqual(message, "exit 1")
        }
    }
}
