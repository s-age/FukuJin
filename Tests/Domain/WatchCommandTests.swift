import XCTest
@testable import FukuJin

final class WatchCommandTests: XCTestCase {
    func test_init_preservesRawString() throws {
        let command = try WatchCommand("echo hi")
        XCTAssertEqual(command.raw, "echo hi")
    }

    func test_init_acceptsCommandAtMaxLength() throws {
        let command = try WatchCommand(String(repeating: "a", count: 1024))
        XCTAssertEqual(command.raw.count, 1024)
    }

    func test_init_rejectsEmptyString() {
        assertThrowsInvalidCommand(try WatchCommand(""))
    }

    func test_init_rejectsWhitespaceOnlyString() {
        assertThrowsInvalidCommand(try WatchCommand("   \t  "))
    }

    func test_init_rejectsStringOverMaxLength() {
        assertThrowsInvalidCommand(try WatchCommand(String(repeating: "a", count: 1025)))
    }

    func test_init_rejectsNullByte() {
        assertThrowsInvalidCommand(try WatchCommand("echo\u{0}hi"))
    }

    func test_init_rejectsNewline() {
        assertThrowsInvalidCommand(try WatchCommand("echo\nrm -rf /"))
    }

    func test_init_rejectsCarriageReturn() {
        assertThrowsInvalidCommand(try WatchCommand("echo\rrm -rf /"))
    }

    private func assertThrowsInvalidCommand(
        _ expression: @autoclosure () throws -> WatchCommand,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard case ValidationError.invalidCommandString = error else {
                return XCTFail("expected .invalidCommandString, got \(error)", file: file, line: line)
            }
        }
    }
}
