protocol RecognitionSettingsDomainServiceProtocol: Sendable {
    func currentLanguages() -> [OCRLanguage]
    func updateLanguages(_ languages: [OCRLanguage]) throws -> [OCRLanguage]
}
