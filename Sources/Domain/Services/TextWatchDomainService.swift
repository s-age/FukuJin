final class TextWatchDomainService: TextWatchDomainServiceProtocol, Sendable {
    private let textRecognitionRepository: any TextRecognitionRepositoryProtocol
    private let commandRepository: any CommandRepositoryProtocol
    private let windowActionService: any WindowActionDomainServiceProtocol
    private let settingsRepository: any SettingsRepositoryProtocol

    init(
        textRecognitionRepository: any TextRecognitionRepositoryProtocol,
        commandRepository: any CommandRepositoryProtocol,
        windowActionService: any WindowActionDomainServiceProtocol,
        settingsRepository: any SettingsRepositoryProtocol
    ) {
        self.textRecognitionRepository = textRecognitionRepository
        self.commandRepository = commandRepository
        self.windowActionService = windowActionService
        self.settingsRepository = settingsRepository
    }

    func scanAndMatch(image: CapturedImageRef, config: ScanConfig) async throws -> TextScanResult {
        guard config.hasSearchTerm else { return .unmatched }
        let languages = settingsRepository.loadRecognitionLanguages()
        let blocks = try await textRecognitionRepository.recognizeText(in: image, languages: languages)
        return TextScanResult.match(blocks: blocks, searchText: config.searchText)
    }

    func executeActions(
        _ actions: [TextWatchAction],
        windowID: UInt32,
        pid: Int32
    ) async -> [TextWatchActionEvent] {
        var events: [TextWatchActionEvent] = []
        for action in actions {
            switch action {
            case .notification:
                events.append(.notificationRequested)
            case .activateWindow:
                windowActionService.raiseWindow(windowID: windowID, pid: pid)
                events.append(.windowActivated)
            case .command(let cmd):
                do {
                    try await commandRepository.execute(cmd)
                    events.append(.commandSucceeded)
                } catch {
                    events.append(.commandFailed(TextWatchCommandFailure(from: error)))
                }
            }
        }
        return events
    }
}
