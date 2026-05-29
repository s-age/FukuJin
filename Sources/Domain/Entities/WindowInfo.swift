import Foundation

struct WindowInfo: Identifiable, Equatable, Sendable {
    let id: UInt32
    let ownerPID: Int32
    let ownerName: String
    /// Raw window title as reported by the window server — never the owner-qualified display
    /// string. Composing "ownerName — windowName" (and the empty-name fallback) is display
    /// formatting and lives in Presentation.
    let windowName: String
}
