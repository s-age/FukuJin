import Foundation

struct ScanTextResponse: Sendable {
    let matched: Bool
    let windowID: UInt32
    let matchedBoundingBoxes: [BoundingBoxResponse]
}
