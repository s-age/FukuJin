import Foundation

enum DomainError: LocalizedError, Sendable {
    case windowNotFound(windowID: UInt32)
    case capturePermissionDenied
    case accessibilityPermissionDenied
    case textRecognitionFailed
    case commandExitedWithNonZeroStatus(message: String)

    var errorDescription: String? {
        switch self {
        case .windowNotFound(let windowID):
            "Window \(windowID) not found"
        case .capturePermissionDenied:
            "Screen capture permission denied"
        case .accessibilityPermissionDenied:
            "Accessibility permission denied"
        case .textRecognitionFailed:
            "Text recognition failed"
        case .commandExitedWithNonZeroStatus(let message):
            "Command failed: \(message)"
        }
    }
}
