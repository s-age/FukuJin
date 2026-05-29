import XCTest
@testable import FukuJin

final class ReorderPinnedWindowsUseCaseTests: XCTestCase {
    private func makeStateWithWindows(_ ids: [UInt32]) -> PinnedWindowList {
        var state = PinnedWindowList.empty
        for id in ids {
            state = state.pinning(
                WindowInfo(id: id, ownerPID: 1, ownerName: "App", windowName: "W\(id)"),
                seed: .default
            )
        }
        return state
    }

    func test_execute_callsServiceReorderOnce_andMapsResponse() throws {
        let mock = PinDomainServiceMock()
        mock.stubbedState = makeStateWithWindows([1, 2, 3]).reordering([3, 1, 2])
        let useCase = ReorderPinnedWindowsUseCase(pinService: mock)

        let response = try useCase.execute(ReorderPinnedWindowsRequest(order: [3, 1, 2]))

        XCTAssertEqual(mock.reorderCallCount, 1)
        XCTAssertEqual(mock.lastReorderArg, [3, 1, 2])
        XCTAssertEqual(response.windowIDs, [3, 1, 2])
        XCTAssertEqual(Set(response.windowIDs), [1, 2, 3])
        XCTAssertTrue(response.hasPinnedWindows)
    }

    func test_windows_followsResponseOrder() throws {
        let mock = PinDomainServiceMock()
        mock.stubbedState = makeStateWithWindows([10, 20, 30]).reordering([30, 10, 20])
        let useCase = ReorderPinnedWindowsUseCase(pinService: mock)

        let response = try useCase.execute(ReorderPinnedWindowsRequest(order: [30, 10, 20]))

        XCTAssertEqual(response.windows.map(\.windowID), [30, 10, 20])
    }

    func test_validation_rejectsEmptyOrder() {
        let request = ReorderPinnedWindowsRequest(order: [])
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.emptyPinOrder = error else {
                return XCTFail("expected .emptyPinOrder, got \(error)")
            }
        }
    }

    func test_validation_rejectsDuplicates() {
        let request = ReorderPinnedWindowsRequest(order: [1, 2, 1])
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.duplicatePinOrder = error else {
                return XCTFail("expected .duplicatePinOrder, got \(error)")
            }
        }
    }

    func test_validation_rejectsZeroID() {
        let request = ReorderPinnedWindowsRequest(order: [1, 0, 2])
        XCTAssertThrowsError(try request.validate()) { error in
            guard case ValidationError.invalidWindowID = error else {
                return XCTFail("expected .invalidWindowID, got \(error)")
            }
        }
    }

    func test_validation_acceptsValidOrder() {
        let request = ReorderPinnedWindowsRequest(order: [1, 2, 3])
        XCTAssertNoThrow(try request.validate())
    }

    func test_decorator_runsValidationBeforeExecute() {
        let mock = PinDomainServiceMock()
        let decorated = ValidationSyncUseCaseDecorator(
            decoratee: ReorderPinnedWindowsUseCase(pinService: mock)
        )

        XCTAssertThrowsError(try decorated.execute(ReorderPinnedWindowsRequest(order: [])))
        XCTAssertEqual(mock.reorderCallCount, 0,
                       "service must not be called when validation fails")
    }

    func test_responseWindowIDs_isPopulatedFromEntity() {
        let state = makeStateWithWindows([5, 6, 7]).reordering([7, 5, 6])
        let response = PinnedWindowListResponse(from: state)
        XCTAssertEqual(response.windowIDs, [7, 5, 6])
        XCTAssertEqual(response.windows.map(\.windowID), [7, 5, 6])
    }
}
