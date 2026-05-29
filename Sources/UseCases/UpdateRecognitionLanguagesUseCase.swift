final class UpdateRecognitionLanguagesUseCase: SyncUseCase, Sendable {
    private let recognitionSettingsService: any RecognitionSettingsDomainServiceProtocol

    init(recognitionSettingsService: any RecognitionSettingsDomainServiceProtocol) {
        self.recognitionSettingsService = recognitionSettingsService
    }

    func execute(_ request: UpdateRecognitionLanguagesRequest) throws -> [OCRLanguageResponse] {
        let updated = try recognitionSettingsService.updateLanguages(request.languages.map(\.toDomain))
        return updated.map(OCRLanguageResponse.init(from:))
    }
}
