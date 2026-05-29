final class SettingsRepository: SettingsRepositoryProtocol, Sendable {
    private let dataSource: any SettingsDataSourceProtocol

    init(dataSource: any SettingsDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func loadDefaultConfig() -> OverlayConfig {
        guard let dto = dataSource.load() else {
            return .default
        }
        return OverlayConfig.create(opacity: dto.opacity, fps: dto.fps)
    }

    func saveDefaultConfig(_ config: OverlayConfig) throws {
        // Read-modify-write: the settings file is a single document shared with the
        // OCR language selection, so preserve any existing sibling fields.
        let existing = dataSource.load()
        let dto = SettingsDTO(
            opacity: config.opacity,
            fps: config.fps,
            ocrLanguages: existing?.ocrLanguages
        )
        try persist(dto)
    }

    func loadRecognitionLanguages() -> [OCRLanguage] {
        let codes = dataSource.load()?.ocrLanguages ?? []
        return OCRLanguage.normalized(codes.compactMap(OCRLanguage.init(rawValue:)))
    }

    func saveRecognitionLanguages(_ languages: [OCRLanguage]) throws {
        let existing = dataSource.load()
        let dto = SettingsDTO(
            opacity: existing?.opacity ?? OverlayConfig.default.opacity,
            fps: existing?.fps ?? OverlayConfig.default.fps,
            ocrLanguages: OCRLanguage.normalized(languages).map(\.rawValue)
        )
        try persist(dto)
    }

    private func persist(_ dto: SettingsDTO) throws {
        do {
            try dataSource.save(dto)
        } catch {
            throw InfrastructureError.settingsPersistenceFailed(message: error.localizedDescription)
        }
    }
}
