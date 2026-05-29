import Foundation

struct BoundingBox: Equatable, Sendable, Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    static let zero = BoundingBox(x: 0, y: 0, width: 0, height: 0)
}
