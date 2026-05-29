import XCTest
@testable import FukuJin

final class WindowGroupTests: XCTestCase {
    private func window(id: UInt32, owner: String) -> WindowInfo {
        WindowInfo(id: id, ownerPID: 1, ownerName: owner, windowName: "w\(id)")
    }

    // MARK: - grouping

    func test_grouping_emptyInput_returnsNoGroups() {
        XCTAssertEqual(WindowGroup.grouping([]), [])
    }

    func test_grouping_singleApp_producesOneGroup() {
        let groups = WindowGroup.grouping([window(id: 1, owner: "Safari"), window(id: 2, owner: "Safari")])
        XCTAssertEqual(groups.count, 1)
    }

    func test_grouping_collectsAllWindowsOfSameApp() {
        let groups = WindowGroup.grouping([window(id: 1, owner: "Safari"), window(id: 2, owner: "Safari")])
        XCTAssertEqual(groups.first?.windows.map(\.id), [1, 2])
    }

    func test_grouping_usesOwnerNameAsGroupID() {
        let groups = WindowGroup.grouping([window(id: 1, owner: "Safari")])
        XCTAssertEqual(groups.first?.id, "Safari")
    }

    func test_grouping_usesOwnerNameAsAppName() {
        let groups = WindowGroup.grouping([window(id: 1, owner: "Safari")])
        XCTAssertEqual(groups.first?.appName, "Safari")
    }

    func test_grouping_preservesFirstSeenAppOrder() {
        let groups = WindowGroup.grouping([
            window(id: 1, owner: "Safari"),
            window(id: 2, owner: "Xcode"),
            window(id: 3, owner: "Safari")
        ])
        XCTAssertEqual(groups.map(\.appName), ["Safari", "Xcode"])
    }

    func test_grouping_preservesWindowOrderWithinGroup_acrossInterleaving() {
        // Window 3 (Safari) appears after an Xcode window but must still join Safari's group
        // in encounter order — grouping does not re-sort within a group.
        let groups = WindowGroup.grouping([
            window(id: 1, owner: "Safari"),
            window(id: 2, owner: "Xcode"),
            window(id: 3, owner: "Safari")
        ])
        XCTAssertEqual(groups.first?.windows.map(\.id), [1, 3])
    }
}
