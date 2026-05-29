import XCTest
@testable import FukuJin

final class CaptureRepositoryTests: XCTestCase {
    private var sut: CaptureRepository!
    private var mockDataSource: CaptureDataSourceMock!
    private var mockImageStore: CapturedImageStoreMock!

    override func setUp() {
        super.setUp()
        mockDataSource = CaptureDataSourceMock()
        mockImageStore = CapturedImageStoreMock()
        sut = CaptureRepository(dataSource: mockDataSource, imageStore: mockImageStore)
    }

    override func tearDown() {
        sut = nil
        mockDataSource = nil
        mockImageStore = nil
        super.tearDown()
    }

    // MARK: - startCapture

    func test_startCapture_callsDataSourceOnce() async throws {
        try await sut.startCapture(windowID: 42, fps: 30)
        XCTAssertEqual(mockDataSource.startCaptureCallCount, 1)
    }

    func test_startCapture_forwardsArguments() async throws {
        try await sut.startCapture(windowID: 42, fps: 30)
        XCTAssertEqual(mockDataSource.lastStartCaptureWindowID, 42)
        XCTAssertEqual(mockDataSource.lastStartCaptureFPS, 30)
    }

    func test_startCapture_mapsWindowNotFoundToDomainError() async throws {
        mockDataSource.startCaptureError = InfrastructureError.windowNotFound(windowID: 99)
        do {
            try await sut.startCapture(windowID: 99, fps: 30)
            XCTFail("Expected DomainError.windowNotFound")
        } catch let error as DomainError {
            guard case .windowNotFound(let id) = error else {
                return XCTFail("Expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(id, 99)
        }
    }

    // MARK: - captureWindowOneShot

    func test_captureWindowOneShot_callsDataSourceOnce() async throws {
        _ = try await sut.captureWindowOneShot(7)
        XCTAssertEqual(mockDataSource.captureWindowOneShotCallCount, 1)
    }

    func test_captureWindowOneShot_forwardsWindowID() async throws {
        _ = try await sut.captureWindowOneShot(7)
        XCTAssertEqual(mockDataSource.lastCaptureWindowOneShotID, 7)
    }

    func test_captureWindowOneShot_mapsWindowNotFoundToDomainError() async throws {
        mockDataSource.captureWindowOneShotError = InfrastructureError.windowNotFound(windowID: 13)
        do {
            _ = try await sut.captureWindowOneShot(13)
            XCTFail("Expected DomainError.windowNotFound")
        } catch let error as DomainError {
            guard case .windowNotFound(let id) = error else {
                return XCTFail("Expected .windowNotFound, got \(error)")
            }
            XCTAssertEqual(id, 13)
        }
    }
}
