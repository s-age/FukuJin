import XCTest
@testable import FukuJin

final class WindowInfoResponsePresentationTests: XCTestCase {
    private func make(ownerName: String, windowName: String) -> WindowInfoResponse {
        WindowInfoResponse(from: WindowInfo(id: 1, ownerPID: 1, ownerName: ownerName, windowName: windowName))
    }

    func test_displayName_isBareWindowName_whenPresent() {
        let response = make(ownerName: "Safari", windowName: "My Page")
        XCTAssertEqual(response.displayName, "My Page")
    }

    func test_displayName_fallsBackToOwnerName_whenWindowNameEmpty() {
        let response = make(ownerName: "Safari", windowName: "")
        XCTAssertEqual(response.displayName, "Safari")
    }
}
