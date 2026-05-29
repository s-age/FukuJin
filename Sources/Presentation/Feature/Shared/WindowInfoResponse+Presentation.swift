import Foundation

extension WindowInfoResponse {
    /// Bare window title for rows shown under an app-name header (the owner is already on screen).
    /// Falls back to the owner name when the window server reports no title.
    var displayName: String {
        windowName.isEmpty ? ownerName : windowName
    }
}
