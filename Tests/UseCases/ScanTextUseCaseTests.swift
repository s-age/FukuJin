import Foundation
import XCTest
@testable import FukuJin

final class ScanTextUseCaseTests: XCTestCase {
    private var sut: ScanTextUseCase!
    private var mockService: TextWatchDomainServiceMock!

    override func setUp() {
        super.setUp()
        mockService = TextWatchDomainServiceMock()
        sut = ScanTextUseCase(textWatchService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    private func makeRequest(
        searchText: String = "needle",
        bounds: ScanTextRequest.Bounds = ScanTextRequest.Bounds(x: 0, y: 0, width: 10, height: 10)
    ) -> ScanTextRequest {
        ScanTextRequest(
            windowID: 1,
            imageID: UUID(),
            bounds: bounds,
            searchText: searchText
        )
    }

    func test_execute_callsScanAndMatchOnce() async throws {
        _ = try await sut.execute(makeRequest())
        XCTAssertEqual(mockService.scanAndMatchCallCount, 1)
    }

    func test_execute_mapsRequestImageToDomainEntity_preservingSnapshotID() async throws {
        let id = UUID()
        let request = ScanTextRequest(
            windowID: 1,
            imageID: id,
            bounds: ScanTextRequest.Bounds(x: 0, y: 0, width: 1, height: 1),
            searchText: "needle"
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(mockService.lastScanImage?.resolution, .oneShot(snapshotID: id))
    }

    func test_execute_mapsRequestBoundsToDomainBounds() async throws {
        let request = makeRequest(
            bounds: ScanTextRequest.Bounds(x: 1.5, y: 2.5, width: 3.5, height: 4.5)
        )
        _ = try await sut.execute(request)
        XCTAssertEqual(
            mockService.lastScanImage?.bounds,
            BoundingBox(x: 1.5, y: 2.5, width: 3.5, height: 4.5)
        )
    }

    func test_execute_returnsMatchedFlagFromService() async throws {
        mockService.stubbedScanResult = TextScanResult(matched: true, matchedBoundingBoxes: [])
        let response = try await sut.execute(makeRequest())
        XCTAssertTrue(response.matched)
    }

    func test_execute_returnsWindowIDFromRequest() async throws {
        let request = ScanTextRequest(
            windowID: 99,
            imageID: UUID(),
            bounds: ScanTextRequest.Bounds(x: 0, y: 0, width: 0, height: 0),
            searchText: "needle"
        )
        let response = try await sut.execute(request)
        XCTAssertEqual(response.windowID, 99)
    }

    func test_execute_mapsMatchedBoundingBoxesToResponseType() async throws {
        let domainBox = BoundingBox(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        mockService.stubbedScanResult = TextScanResult(
            matched: true,
            matchedBoundingBoxes: [domainBox]
        )
        let response = try await sut.execute(makeRequest())
        XCTAssertEqual(
            response.matchedBoundingBoxes,
            [BoundingBoxResponse(x: 0.1, y: 0.2, width: 0.3, height: 0.4)]
        )
    }
}
