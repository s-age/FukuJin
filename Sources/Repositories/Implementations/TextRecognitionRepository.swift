final class TextRecognitionRepository: TextRecognitionRepositoryProtocol, Sendable {
    private let dataSource: any TextRecognitionDataSourceProtocol
    private let imageStore: any CapturedImageStoreProtocol

    init(
        dataSource: any TextRecognitionDataSourceProtocol,
        imageStore: any CapturedImageStoreProtocol
    ) {
        self.dataSource = dataSource
        self.imageStore = imageStore
    }

    func recognizeText(in image: CapturedImageRef, languages: [OCRLanguage]) async throws -> [RecognizedTextBlock] {
        guard case .oneShot(let snapshotID) = image.resolution,
              let cgImage = imageStore.resolve(snapshotID) else { return [] }
        let codes = languages.map(\.rawValue)
        return try await dataSource.recognizeText(in: cgImage, languages: codes).map {
            RecognizedTextBlock(text: $0.text, boundingBox: BoundingBox($0.boundingBox))
        }
    }
}
