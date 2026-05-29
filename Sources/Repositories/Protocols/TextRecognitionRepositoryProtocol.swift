protocol TextRecognitionRepositoryProtocol: Sendable {
    func recognizeText(in image: CapturedImageRef, languages: [OCRLanguage]) async throws -> [RecognizedTextBlock]
}
