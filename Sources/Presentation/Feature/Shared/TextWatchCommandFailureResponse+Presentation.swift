import Foundation

extension TextWatchCommandFailureResponse {
    /// User-facing description of a command failure. Display formatting lives in
    /// Presentation — the Domain layer only classifies the failure kind.
    var displayMessage: String {
        switch self {
        case .exitedWithNonZeroStatus(let status):
            String(localized: "Command failed: \(status)")
        case .executionFailed:
            String(localized: "Command could not be executed")
        }
    }
}
