import XCTest
@testable import FukuJin

final class WindowFocusReconcilerTests: XCTestCase {
    private var sut: WindowFocusReconciler!

    override func setUp() {
        super.setUp()
        sut = WindowFocusReconciler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - windowFocused

    func test_windowFocused_setsFrontmostOwnerAndExplicitOrigin() {
        let result = sut.reconcile(current: .none, event: .windowFocused(windowID: 7, ownerPID: 100))
        XCTAssertEqual(result, .focused(windowID: 7, ownerPID: 100, origin: .explicit))
    }

    func test_windowFocused_overridesExistingFocus() {
        let current = WindowFocusState.focused(windowID: 1, ownerPID: 100, origin: .explicit)
        let result = sut.reconcile(current: current, event: .windowFocused(windowID: 2, ownerPID: 200))
        XCTAssertEqual(result, .focused(windowID: 2, ownerPID: 200, origin: .explicit))
    }

    // MARK: - appActivated with observation

    func test_appActivated_withObservedPinnedWindow_setsObservedOrigin() {
        let result = sut.reconcile(
            current: .none, event: .appActivated(pid: 100, observedFrontmostPinnedWindowID: 7)
        )
        XCTAssertEqual(result, .focused(windowID: 7, ownerPID: 100, origin: .observed))
    }

    // MARK: - appActivated without observation (lag guard — regression fix)

    func test_appActivated_emptyObservation_sameApp_explicitFocus_keepsCurrentFocus() {
        // CGWindowList lag: the user just focused window 7, its app re-activates, but the OS hasn't
        // surfaced the window yet (observed == nil). The explicit focus must be kept so the overlay
        // does not re-cover the real window the user just focused.
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcile(
            current: current, event: .appActivated(pid: 100, observedFrontmostPinnedWindowID: nil)
        )
        XCTAssertEqual(result, current)
    }

    func test_appActivated_emptyObservation_sameApp_observedFocus_clearsFocus() {
        // No pending raise to guard (the focus was itself OS-observed), so a fresh empty
        // observation for the same app is authoritative and must clear the focus — not falsely
        // retain it.
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .observed)
        let result = sut.reconcile(
            current: current, event: .appActivated(pid: 100, observedFrontmostPinnedWindowID: nil)
        )
        XCTAssertEqual(result, .none)
    }

    func test_appActivated_emptyObservation_differentApp_clearsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcile(
            current: current, event: .appActivated(pid: 200, observedFrontmostPinnedWindowID: nil)
        )
        XCTAssertEqual(result, .none)
    }

    func test_appActivated_emptyObservation_noCurrentFocus_isNone() {
        let result = sut.reconcile(
            current: .none, event: .appActivated(pid: 100, observedFrontmostPinnedWindowID: nil)
        )
        XCTAssertEqual(result, .none)
    }

    // MARK: - windowUnpinned (disappearance variant)

    func test_windowUnpinned_matchingFocus_clearsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcile(current: current, event: .windowUnpinned(windowID: 7))
        XCTAssertEqual(result, .none)
    }

    func test_windowUnpinned_unrelatedWindow_keepsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcile(current: current, event: .windowUnpinned(windowID: 8))
        XCTAssertEqual(result, current)
    }

    func test_windowUnpinned_noCurrentFocus_staysNone() {
        let result = sut.reconcile(current: .none, event: .windowUnpinned(windowID: 7))
        XCTAssertEqual(result, .none)
    }

    // MARK: - reconcileLiveness (re-validation against a fresh pin snapshot)

    private func pinnedList(ids: [UInt32]) -> PinnedWindowList {
        ids.reduce(PinnedWindowList.empty) { list, id in
            list.pinning(WindowInfo(id: id, ownerPID: 100, ownerName: "App", windowName: "w"), seed: .default)
        }
    }

    func test_reconcileLiveness_focusStillPinned_keepsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcileLiveness(current: current, against: pinnedList(ids: [7]))
        XCTAssertEqual(result, current)
    }

    func test_reconcileLiveness_focusNoLongerPinned_clearsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .explicit)
        let result = sut.reconcileLiveness(current: current, against: pinnedList(ids: [8]))
        XCTAssertEqual(result, .none)
    }

    func test_reconcileLiveness_emptySnapshot_clearsFocus() {
        let current = WindowFocusState.focused(windowID: 7, ownerPID: 100, origin: .observed)
        let result = sut.reconcileLiveness(current: current, against: .empty)
        XCTAssertEqual(result, .none)
    }

    func test_reconcileLiveness_noCurrentFocus_staysNone() {
        let result = sut.reconcileLiveness(current: .none, against: pinnedList(ids: [7]))
        XCTAssertEqual(result, .none)
    }
}
