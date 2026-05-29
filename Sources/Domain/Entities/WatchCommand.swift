import Foundation

/// A shell command bound to a TextWatch action.
///
/// The string reaches `sh -c` in Infrastructure, so this value object is the
/// single domain-side gate that enforces the same constraints the UseCase
/// `Request.validate()` checks — defence in depth against malformed or
/// injection-prone input.
struct WatchCommand: Equatable, Sendable {
    let raw: String

    init(_ raw: String) throws {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.invalidCommandString("must not be empty")
        }
        guard raw.count <= 1024 else {
            throw ValidationError.invalidCommandString("must be 1024 characters or fewer")
        }
        guard !raw.contains("\u{0}") else {
            throw ValidationError.invalidCommandString("must not contain null bytes")
        }
        guard !raw.contains("\n"), !raw.contains("\r") else {
            throw ValidationError.invalidCommandString("must not contain line breaks")
        }
        self.raw = raw
    }
}
