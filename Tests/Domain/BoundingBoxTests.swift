import XCTest
@testable import FukuJin

final class BoundingBoxTests: XCTestCase {
    func test_init_storesXValue() {
        let box = BoundingBox(x: 1.5, y: 2, width: 3, height: 4)
        XCTAssertEqual(box.x, 1.5)
    }

    func test_init_storesYValue() {
        let box = BoundingBox(x: 1, y: 2.5, width: 3, height: 4)
        XCTAssertEqual(box.y, 2.5)
    }

    func test_init_storesWidthValue() {
        let box = BoundingBox(x: 1, y: 2, width: 3.5, height: 4)
        XCTAssertEqual(box.width, 3.5)
    }

    func test_init_storesHeightValue() {
        let box = BoundingBox(x: 1, y: 2, width: 3, height: 4.5)
        XCTAssertEqual(box.height, 4.5)
    }

    func test_zero_hasAllFieldsEqualToZero() {
        XCTAssertEqual(BoundingBox.zero, BoundingBox(x: 0, y: 0, width: 0, height: 0))
    }

    func test_equality_returnsTrue_forSameValues() {
        let lhs = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let rhs = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        XCTAssertEqual(lhs, rhs)
    }

    func test_equality_returnsFalse_forDifferentX() {
        let lhs = BoundingBox(x: 1, y: 2, width: 3, height: 4)
        let rhs = BoundingBox(x: 99, y: 2, width: 3, height: 4)
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_codable_roundTripsAllFields() throws {
        let original = BoundingBox(x: 1.5, y: 2.25, width: 3.125, height: 4.0625)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BoundingBox.self, from: data)
        XCTAssertEqual(decoded, original)
    }
}
