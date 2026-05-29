final class GetRecognitionLanguagesUseCase: SyncUseCase, Sendable {
    private let recognitionSettingsService: any RecognitionSettingsDomainServiceProtocol

    init(recognitionSettingsService: any RecognitionSettingsDomainServiceProtocol) {
        self.recognitionSettingsService = recognitionSettingsService
    }

    func execute(_ request: GetRecognitionLanguagesRequest) throws -> [OCRLanguageResponse] {
        recognitionSettingsService.currentLanguages().map(OCRLanguageResponse.init(from:))
    }
}
