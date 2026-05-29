import CoreGraphics

struct RecognizedTextBlockDTO: Sendable {
    let text: String
    let boundingBox: CGRect
}
