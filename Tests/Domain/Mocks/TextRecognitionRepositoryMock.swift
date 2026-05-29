import Foundation
import os
@testable import FukuJin

final class TextRecognitionRepositoryMock: TextRecognitionRepositoryProtocol, @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock<Void>(initialState: ())

    private(set) var recognizeTextCallCount = 0
    private(set) var lastRecognizedImage: CapturedImageRef?
    private(set) var lastRecognizedLanguages: [OCRLanguage] = []
    var stubbedBlocks: [RecognizedTextBlock] = []
    var recognizeTextError: Error?

    func recognizeText(in image: CapturedImageRef, languages: [OCRLanguage]) async throws -> [RecognizedTextBlock] {
        lock.withLock { _ in
            recognizeTextCallCount += 1
            lastRecognizedImage = image
            lastRecognizedLanguages = languages
        }
        if let error = recognizeTextError { throw error }
        return stubbedBlocks
    }
}
