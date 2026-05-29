import Foundation

struct RecognizedTextBlock: Equatable, Sendable {
    let text: String
    let boundingBox: BoundingBox
}
