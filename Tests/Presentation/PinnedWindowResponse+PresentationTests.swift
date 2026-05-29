import XCTest
@testable import FukuJin

final class PinnedWindowResponsePresentationTests: XCTestCase {
    private func make(ownerName: String, windowName: String) -> PinnedWindowResponse {
        PinnedWindowResponse(
            from: PinnedWindow(
                window: WindowInfo(id: 1, ownerPID: 1, ownerName: ownerName, windowName: windowName),
                opacity: 0.5,
                fps: 1,
                scan: .default
            )
        )
    }

    func test_displayTitle_qualifiesWindowNameWithOwner() {
        let response = make(ownerName: "Safari", windowName: "My Page")
        XCTAssertEqual(response.displayTitle, "Safari \u{2014} My Page")
    }

    func test_displayTitle_fallsBackToOwnerName_whenWindowNameEmpty() {
        let response = make(ownerName: "Safari", windowName: "")
        XCTAssertEqual(response.displayTitle, "Safari")
    }
}
