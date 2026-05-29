protocol SettingsDataSourceProtocol: Sendable {
    func load() -> SettingsDTO?
    func save(_ dto: SettingsDTO) throws
}
