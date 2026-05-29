import Foundation

/// Domain-level classification of why a watch command failed.
///
/// Carries failure *kind* (and raw data such as exit status) — never a
/// localized/display string. Turning this into user-facing text is the
/// Presentation layer's responsibility.
enum TextWatchCommandFailure: Equatable, Sendable {
    /// The process ran but exited with a non-zero status. `status` is the raw
    /// process status reported by Infrastructure, not a localized message.
    case exitedWithNonZeroStatus(status: String)
    /// The command could not be executed or failed for an unclassified reason.
    case executionFailed

    /// Classifies a command-execution error into a domain failure kind.
    /// A non-zero exit carries through the raw status; anything else is unclassified.
    init(from error: Error) {
        switch error {
        case DomainError.commandExitedWithNonZeroStatus(let message):
            self = .exitedWithNonZeroStatus(status: message)
        default:
            self = .executionFailed
        }
    }
}
