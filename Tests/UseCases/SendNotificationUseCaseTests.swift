import XCTest
@testable import FukuJin

final class SendNotificationUseCaseTests: XCTestCase {
    private var sut: SendNotificationUseCase!
    private var mockDomainService: NotificationDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockDomainService = NotificationDomainServiceMock()
        sut = SendNotificationUseCase(notificationService: mockDomainService)
    }

    override func tearDown() {
        sut = nil
        mockDomainService = nil
        super.tearDown()
    }

    func test_execute_callsDomainServiceOnce() async throws {
        try await sut.execute(SendNotificationRequest(title: "Title", body: "Body"))
        XCTAssertEqual(mockDomainService.sendCallCount, 1)
    }

    func test_execute_forwardsTitle() async throws {
        try await sut.execute(SendNotificationRequest(title: "Hello", body: "Body"))
        XCTAssertEqual(mockDomainService.lastTitle, "Hello")
    }

    func test_execute_forwardsBody() async throws {
        try await sut.execute(SendNotificationRequest(title: "Title", body: "World"))
        XCTAssertEqual(mockDomainService.lastBody, "World")
    }

    func test_execute_propagatesDomainServiceError() async {
        struct StubError: Error, Equatable {}
        mockDomainService.sendError = StubError()
        do {
            try await sut.execute(SendNotificationRequest(title: "Title", body: "Body"))
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is StubError)
        }
    }

    func test_validation_rejectsEmptyTitle() {
        let request = SendNotificationRequest(title: "", body: "Body")
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.emptyNotificationTitle = error else {
                return XCTFail("expected .emptyNotificationTitle, got \(error)")
            }
        }
    }

    func test_validation_acceptsEmptyBody() {
        let request = SendNotificationRequest(title: "Title", body: "")
        XCTAssertNoThrow(try request.validate())
    }

    func test_validation_acceptsValidRequest() {
        let request = SendNotificationRequest(title: "Title", body: "Body")
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_skipsExecuteWhenValidationFails() async {
        let decorated = ValidationAsyncUseCaseDecorator(decoratee: sut!)
        do {
            try await decorated.execute(SendNotificationRequest(title: "", body: "Body"))
            XCTFail("Expected validation error")
        } catch {
            XCTAssertEqual(mockDomainService.sendCallCount, 0,
                           "domain service must not be called when validation fails")
        }
    }
}
