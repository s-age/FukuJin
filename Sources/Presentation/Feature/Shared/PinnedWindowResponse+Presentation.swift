import Foundation

extension PinnedWindowResponse {
    /// Owner-qualified title for rows that are not grouped under an app header (pinned menu list,
    /// settings card). Falls back to the owner name alone when the window server reports no title.
    var displayTitle: String {
        windowName.isEmpty ? ownerName : "\(ownerName) \u{2014} \(windowName)"
    }
}
