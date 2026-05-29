import Foundation

struct BoundingBoxResponse: Equatable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

extension BoundingBoxResponse {
    init(from box: BoundingBox) {
        self.init(x: box.x, y: box.y, width: box.width, height: box.height)
    }
}
