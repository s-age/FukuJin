import XCTest
@testable import FukuJin

final class PinnedWindowListTests: XCTestCase {
    private func makeWindow(id: UInt32, owner: String = "App", windowName: String = "Window") -> WindowInfo {
        WindowInfo(id: id, ownerPID: 100, ownerName: owner, windowName: windowName)
    }

    private func pin(_ list: PinnedWindowList, _ window: WindowInfo) -> PinnedWindowList {
        list.pinning(window, seed: .default)
    }

    func test_empty_hasNoWindowsAndEmptyIDs() {
        let list = PinnedWindowList.empty
        XCTAssertTrue(list.windows.isEmpty)
        XCTAssertEqual(list.windowIDs, [])
        XCTAssertFalse(list.hasPinnedWindows)
    }

    func test_pinning_appendsIDToEnd() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        XCTAssertEqual(list.windowIDs, [1, 2, 3])
    }

    func test_pinning_seedsOpacityAndFPSFromConfig() {
        let seed = OverlayConfig.create(opacity: 0.7, fps: 12)
        let list = PinnedWindowList.empty.pinning(makeWindow(id: 1), seed: seed)
        XCTAssertEqual(list[1]?.opacity, 0.7)
        XCTAssertEqual(list[1]?.fps, 12)
    }

    func test_pinning_ignoredWhenIDAlreadyExists() {
        var list = pin(.empty, makeWindow(id: 1, windowName: "A"))
        list = pin(list, makeWindow(id: 1, windowName: "B"))
        XCTAssertEqual(list.windowIDs, [1])
        XCTAssertEqual(list[1]?.window.windowName, "A")
    }

    func test_unpinning_removesWindow() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        list = list.unpinning(2)
        XCTAssertEqual(list.windowIDs, [1, 3])
    }

    func test_unpinningAll_clearsWindows() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = list.unpinningAll()
        XCTAssertEqual(list.windowIDs, [])
        XCTAssertTrue(list.windows.isEmpty)
    }

    func test_isPinned_reflectsMembership() {
        let list = pin(.empty, makeWindow(id: 1))
        XCTAssertTrue(list.isPinned(1))
        XCTAssertFalse(list.isPinned(2))
    }

    func test_subscript_returnsMatchingWindow() {
        let list = pin(.empty, makeWindow(id: 7, windowName: "Seven"))
        XCTAssertEqual(list[7]?.window.windowName, "Seven")
        XCTAssertNil(list[99])
    }

    func test_pruning_removesStaleIDs() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        list = list.pruning(keeping: [1, 3])
        XCTAssertEqual(list.windowIDs, [1, 3])
    }

    func test_reordering_withFullList_setsOrderExactly() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        list = list.reordering([3, 1, 2])
        XCTAssertEqual(list.windowIDs, [3, 1, 2])
    }

    func test_reordering_dropsDuplicatedIDs() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        list = list.reordering([3, 3, 1, 1, 2])
        XCTAssertEqual(list.windowIDs, [3, 1, 2])
    }

    func test_reordering_ignoresUnknownIDs() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = list.reordering([99, 1, 2])
        XCTAssertEqual(list.windowIDs, [1, 2])
    }

    func test_reordering_keepsMissingWindowsAtTail() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1))
        list = pin(list, makeWindow(id: 2))
        list = pin(list, makeWindow(id: 3))
        list = list.reordering([3])
        XCTAssertEqual(list.windowIDs.first, 3)
        XCTAssertEqual(Set(list.windowIDs), [1, 2, 3])
        XCTAssertEqual(list.windowIDs.count, 3)
    }

    func test_windows_followsReorderedOrder() {
        var list = PinnedWindowList.empty
        list = pin(list, makeWindow(id: 1, windowName: "first"))
        list = pin(list, makeWindow(id: 2, windowName: "second"))
        list = pin(list, makeWindow(id: 3, windowName: "third"))
        list = list.reordering([3, 1, 2])
        XCTAssertEqual(list.windows.map(\.id), [3, 1, 2])
    }

    func test_mutatingWindow_appliesTransform() throws {
        var list = pin(.empty, makeWindow(id: 1))
        list = try list.mutatingWindow(1) { $0.applyingOpacity(0.9) }
        XCTAssertEqual(list[1]?.opacity, 0.9)
    }

    func test_mutatingWindow_throwsForUnknownID() {
        let list = pin(.empty, makeWindow(id: 1))
        XCTAssertThrowsError(try list.mutatingWindow(99) { $0 }) { error in
            guard case DomainError.windowNotFound(let windowID) = error else {
                return XCTFail("expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(windowID, 99)
        }
    }

    func test_equatable_distinguishesDifferentOrders() {
        var base = PinnedWindowList.empty
        base = pin(base, makeWindow(id: 1))
        base = pin(base, makeWindow(id: 2))
        XCTAssertNotEqual(base, base.reordering([2, 1]))
    }

    func test_invariant_windowIDsMatchWindowsAfterMixedOperations() {
        var list = PinnedWindowList.empty
        for id in UInt32(1)...UInt32(5) {
            list = pin(list, makeWindow(id: id))
        }
        list = list.reordering([5, 3, 1, 2, 4])
        list = list.unpinning(3)
        list = pin(list, makeWindow(id: 6))
        list = list.pruning(keeping: [1, 2, 4, 6])
        XCTAssertEqual(list.windowIDs, list.windows.map(\.id))
        XCTAssertEqual(Set(list.windowIDs), [1, 2, 4, 6])
    }
}
