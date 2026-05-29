import Synchronization

/// Owns the app-global OCR matching-language selection.
///
/// Caches the persisted selection in a `Mutex` for fast UI reads and writes through to
/// the settings store on update. `TextWatchDomainService` reads the languages straight
/// from the settings repository at scan time, so the freshly-written value is picked up
/// without any service-to-service coupling.
final class RecognitionSettingsDomainService: RecognitionSettingsDomainServiceProtocol, Sendable {
    private let settingsRepository: any SettingsRepositoryProtocol
    private let languagesState: Mutex<[OCRLanguage]>

    init(settingsRepository: any SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
        self.languagesState = Mutex(settingsRepository.loadRecognitionLanguages())
    }

    func currentLanguages() -> [OCRLanguage] {
        languagesState.withLock { $0 }
    }

    func updateLanguages(_ languages: [OCRLanguage]) throws -> [OCRLanguage] {
        let normalized = OCRLanguage.normalized(languages)
        try settingsRepository.saveRecognitionLanguages(normalized)
        languagesState.withLock { $0 = normalized }
        return normalized
    }
}
