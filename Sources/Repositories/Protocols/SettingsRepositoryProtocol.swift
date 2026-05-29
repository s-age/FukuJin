protocol SettingsRepositoryProtocol: Sendable {
    func loadDefaultConfig() -> OverlayConfig
    func saveDefaultConfig(_ config: OverlayConfig) throws
    func loadRecognitionLanguages() -> [OCRLanguage]
    func saveRecognitionLanguages(_ languages: [OCRLanguage]) throws
}
