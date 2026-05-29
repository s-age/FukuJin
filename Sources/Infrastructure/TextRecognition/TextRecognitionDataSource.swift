import CoreGraphics
import Vision

final class TextRecognitionDataSource: TextRecognitionDataSourceProtocol, Sendable {
    func recognizeText(in image: CGImage, languages: [String]) async throws -> [RecognizedTextBlockDTO] {
        try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = languages
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try handler.perform([request])
            guard let observations = request.results else { return [] }
            return observations.compactMap { observation -> RecognizedTextBlockDTO? in
                guard let text = observation.topCandidates(1).first?.string else { return nil }
                return RecognizedTextBlockDTO(text: text, boundingBox: observation.boundingBox)
            }
        }.value
    }
}
