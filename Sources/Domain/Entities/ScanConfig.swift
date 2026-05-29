import Foundation

struct ScanConfig: Equatable, Sendable {
    let searchText: String
    let actions: [TextWatchAction]
    let isScanning: Bool

    private init(searchText: String, actions: [TextWatchAction], isScanning: Bool) {
        self.searchText = searchText
        self.actions = actions
        self.isScanning = isScanning
    }

    static let `default` = ScanConfig(searchText: "", actions: [], isScanning: false)

    var isCapturing: Bool {
        isScanning && !searchText.isEmpty && !actions.isEmpty
    }

    var hasSearchTerm: Bool {
        isScanning && !searchText.isEmpty
    }

    func applying(searchText: String) -> ScanConfig {
        ScanConfig(searchText: searchText, actions: actions, isScanning: isScanning)
    }

    func applying(isScanning: Bool) -> ScanConfig {
        ScanConfig(searchText: searchText, actions: actions, isScanning: isScanning)
    }

    func applying(actions: [TextWatchAction]) -> ScanConfig {
        ScanConfig(searchText: searchText, actions: actions, isScanning: isScanning)
    }

    func togglingAction(_ action: TextWatchAction) -> ScanConfig {
        var updated = actions
        if let index = updated.firstIndex(of: action) {
            updated.remove(at: index)
        } else {
            updated.append(action)
        }
        return ScanConfig(searchText: searchText, actions: updated, isScanning: isScanning)
    }
}
