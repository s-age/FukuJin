import CoreGraphics

protocol TextRecognitionDataSourceProtocol: Sendable {
    func recognizeText(in image: CGImage, languages: [String]) async throws -> [RecognizedTextBlockDTO]
}
