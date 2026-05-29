import XCTest
@testable import FukuJin

final class TextWatchCommandFailureTests: XCTestCase {
    // MARK: - init(from:)

    func test_init_fromNonZeroExit_carriesRawStatusThrough() {
        let failure = TextWatchCommandFailure(from: DomainError.commandExitedWithNonZeroStatus(message: "exit 1"))
        XCTAssertEqual(failure, .exitedWithNonZeroStatus(status: "exit 1"))
    }

    func test_init_fromUnrelatedDomainError_isExecutionFailed() {
        let failure = TextWatchCommandFailure(from: DomainError.textRecognitionFailed)
        XCTAssertEqual(failure, .executionFailed)
    }

    func test_init_fromGenericError_isExecutionFailed() {
        struct StubError: Error {}
        let failure = TextWatchCommandFailure(from: StubError())
        XCTAssertEqual(failure, .executionFailed)
    }
}
