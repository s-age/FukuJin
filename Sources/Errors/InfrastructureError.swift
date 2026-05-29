import Foundation

enum InfrastructureError: LocalizedError, Sendable {
    case windowNotFound(windowID: UInt32)
    case processExitedNonZero(status: String)
    case settingsPersistenceFailed(message: String)

    var errorDescription: String? {
        switch self {
        case .windowNotFound(let windowID):
            "Window \(windowID) not found"
        case .processExitedNonZero(let status):
            "Process exited with non-zero status — \(status)"
        case .settingsPersistenceFailed(let message):
            "Settings persistence failed — \(message)"
        }
    }
}
