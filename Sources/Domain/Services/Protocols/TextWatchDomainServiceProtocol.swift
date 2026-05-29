protocol TextWatchDomainServiceProtocol: Sendable {
    func scanAndMatch(image: CapturedImageRef, config: ScanConfig) async throws -> TextScanResult
    func executeActions(
        _ actions: [TextWatchAction],
        windowID: UInt32,
        pid: Int32
    ) async -> [TextWatchActionEvent]
}
