import XCTest
@testable import FukuJin

final class NotificationDomainServiceTests: XCTestCase {
    private var sut: NotificationDomainService!
    private var mockRepository: NotificationRepositoryMock!

    override func setUp() {
        super.setUp()
        mockRepository = NotificationRepositoryMock()
        sut = NotificationDomainService(notificationRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_send_callsRepositoryOnce() async throws {
        try await sut.send(title: "Title", body: "Body")
        XCTAssertEqual(mockRepository.sendNotificationCallCount, 1)
    }

    func test_send_forwardsTitle() async throws {
        try await sut.send(title: "Hello", body: "Body")
        XCTAssertEqual(mockRepository.lastTitle, "Hello")
    }

    func test_send_forwardsBody() async throws {
        try await sut.send(title: "Title", body: "World")
        XCTAssertEqual(mockRepository.lastBody, "World")
    }

    func test_send_propagatesRepositoryError() async {
        struct StubError: Error, Equatable {}
        mockRepository.sendNotificationError = StubError()
        do {
            try await sut.send(title: "Title", body: "Body")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is StubError)
        }
    }
}
