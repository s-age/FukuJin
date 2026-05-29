import SwiftUI

@Observable
@MainActor
final class SettingsViewModel {
    private(set) var defaultConfig: OverlayConfigResponse
    private(set) var recognitionLanguages: [OCRLanguageResponse]
    private let menuBarViewModel: MenuBarViewModel
    private let getDefaultConfig: GetDefaultConfigUseCaseProtocol
    private let updateDefaultConfig: UpdateDefaultConfigUseCaseProtocol
    private let updateScanConfig: UpdateScanConfigUseCaseProtocol
    private let getRecognitionLanguages: GetRecognitionLanguagesUseCaseProtocol
    private let updateRecognitionLanguages: UpdateRecognitionLanguagesUseCaseProtocol

    var pinnedWindows: PinnedWindowListResponse { menuBarViewModel.pinnedWindows }

    var availableLanguages: [OCRLanguageResponse] { OCRLanguageResponse.allCases }

    init(
        menuBarViewModel: MenuBarViewModel,
        getDefaultConfig: GetDefaultConfigUseCaseProtocol,
        updateDefaultConfig: UpdateDefaultConfigUseCaseProtocol,
        updateScanConfig: UpdateScanConfigUseCaseProtocol,
        getRecognitionLanguages: GetRecognitionLanguagesUseCaseProtocol,
        updateRecognitionLanguages: UpdateRecognitionLanguagesUseCaseProtocol
    ) {
        self.menuBarViewModel = menuBarViewModel
        self.getDefaultConfig = getDefaultConfig
        self.updateDefaultConfig = updateDefaultConfig
        self.updateScanConfig = updateScanConfig
        self.getRecognitionLanguages = getRecognitionLanguages
        self.updateRecognitionLanguages = updateRecognitionLanguages
        self.defaultConfig = (try? getDefaultConfig.execute(GetDefaultConfigRequest()))
            ?? OverlayConfigResponse(opacity: 0.5, fps: 1.0)
        self.recognitionLanguages =
            (try? getRecognitionLanguages.execute(GetRecognitionLanguagesRequest())) ?? [.english]
    }

    func appIcon(localizedName: String) -> Image? {
        menuBarViewModel.appIcon(localizedName: localizedName)
    }

    func updateDefaultOpacity(_ value: Double) {
        let request = UpdateDefaultConfigRequest(opacity: value, fps: nil)
        if let result = try? updateDefaultConfig.execute(request) {
            defaultConfig = result
        }
    }

    func updateDefaultFPS(_ value: Double) {
        let request = UpdateDefaultConfigRequest(opacity: nil, fps: value.rounded())
        if let result = try? updateDefaultConfig.execute(request) {
            defaultConfig = result
        }
    }

    func updateOpacity(windowID: UInt32, _ value: Double) {
        menuBarViewModel.updateOpacity(windowID: windowID, value)
    }

    func updateFPS(windowID: UInt32, _ value: Double) {
        menuBarViewModel.updateFPS(windowID: windowID, value)
    }

    func reorderPinnedWindows(_ newOrder: [UInt32]) {
        menuBarViewModel.reorderPinnedWindows(newOrder)
    }

    func updateTextWatchSearch(windowID: UInt32, searchText: String) {
        let request = UpdateScanConfigRequest(
            windowID: windowID,
            searchText: searchText,
            actions: nil,
            isScanning: nil
        )
        if let result = try? updateScanConfig.execute(request) {
            menuBarViewModel.updatePinnedWindows(result)
        }
    }

    func updateTextWatchAction(windowID: UInt32, action: TextWatchActionDTO) {
        let request = UpdateScanConfigRequest(
            windowID: windowID,
            searchText: nil,
            actions: [action],
            isScanning: nil
        )
        if let result = try? updateScanConfig.execute(request) {
            menuBarViewModel.updatePinnedWindows(result)
        }
    }

    func setScanning(windowID: UInt32, isScanning: Bool) {
        menuBarViewModel.setScanning(windowID: windowID, isScanning)
    }

    func isScanning(windowID: UInt32) -> Bool {
        menuBarViewModel.isScanning(windowID: windowID)
    }

    func refreshDefaultConfig() {
        defaultConfig = (try? getDefaultConfig.execute(GetDefaultConfigRequest()))
            ?? defaultConfig
    }

    func isLanguageSelected(_ language: OCRLanguageResponse) -> Bool {
        recognitionLanguages.contains(language)
    }

    func toggleLanguage(_ language: OCRLanguageResponse) {
        var next = recognitionLanguages
        if let index = next.firstIndex(of: language) {
            next.remove(at: index)
        } else {
            next.append(language)
        }
        let request = UpdateRecognitionLanguagesRequest(languages: next)
        if let result = try? updateRecognitionLanguages.execute(request) {
            recognitionLanguages = result
        }
    }

    func refreshRecognitionLanguages() {
        recognitionLanguages = (try? getRecognitionLanguages.execute(GetRecognitionLanguagesRequest()))
            ?? recognitionLanguages
    }
}
