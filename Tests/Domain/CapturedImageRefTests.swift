import XCTest
@testable import FukuJin

final class CapturedImageRefTests: XCTestCase {
    func test_init_storesOneShotResolution() {
        let id = UUID()
        let image = CapturedImageRef(resolution: .oneShot(snapshotID: id), windowID: 1, bounds: BoundingBox.zero)
        XCTAssertEqual(image.resolution, .oneShot(snapshotID: id))
    }

    func test_init_streamingFrame_hasStreamingResolution() {
        let image = CapturedImageRef(resolution: .streaming, windowID: 1, bounds: BoundingBox.zero)
        XCTAssertEqual(image.resolution, .streaming)
    }

    func test_init_storesWindowID() {
        let image = CapturedImageRef(resolution: .streaming, windowID: 99, bounds: BoundingBox.zero)
        XCTAssertEqual(image.windowID, 99)
    }

    func test_init_storesBounds() {
        let bounds = BoundingBox(x: 10, y: 20, width: 100, height: 200)
        let image = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 1, bounds: bounds)
        XCTAssertEqual(image.bounds, bounds)
    }

    func test_equality_returnsTrue_forIdenticalFields() {
        let id = UUID()
        let bounds = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let lhs = CapturedImageRef(resolution: .oneShot(snapshotID: id), windowID: 7, bounds: bounds)
        let rhs = CapturedImageRef(resolution: .oneShot(snapshotID: id), windowID: 7, bounds: bounds)
        XCTAssertEqual(lhs, rhs)
    }

    func test_equality_returnsFalse_forDifferentSnapshotID() {
        let bounds = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let lhs = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 7, bounds: bounds)
        let rhs = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 7, bounds: bounds)
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_returnsFalse_forDifferentResolutionMode() {
        let bounds = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let lhs = CapturedImageRef(resolution: .oneShot(snapshotID: UUID()), windowID: 7, bounds: bounds)
        let rhs = CapturedImageRef(resolution: .streaming, windowID: 7, bounds: bounds)
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_returnsFalse_forDifferentWindowID() {
        let bounds = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let lhs = CapturedImageRef(resolution: .streaming, windowID: 1, bounds: bounds)
        let rhs = CapturedImageRef(resolution: .streaming, windowID: 2, bounds: bounds)
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_returnsFalse_forDifferentBounds() {
        let id = UUID()
        let lhs = CapturedImageRef(
            resolution: .oneShot(snapshotID: id),
            windowID: 7,
            bounds: BoundingBox(x: 1, y: 2, width: 3, height: 4)
        )
        let rhs = CapturedImageRef(
            resolution: .oneShot(snapshotID: id),
            windowID: 7,
            bounds: BoundingBox(x: 9, y: 2, width: 3, height: 4)
        )
        XCTAssertNotEqual(lhs, rhs)
    }
}
