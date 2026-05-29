protocol LoginItemRepositoryProtocol: Sendable {
    func isEnabled() -> Bool
    func setEnabled(_ enabled: Bool) throws
}
