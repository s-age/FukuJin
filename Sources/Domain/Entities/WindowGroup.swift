import Foundation

struct WindowGroup: Identifiable, Equatable, Sendable {
    let id: String
    let appName: String
    let windows: [WindowInfo]

    /// Buckets windows by owning app, preserving the first-seen order of each app.
    /// Input order is assumed to carry meaning (e.g. z-order), so neither the groups
    /// nor the windows within a group are re-sorted.
    static func grouping(_ windows: [WindowInfo]) -> [WindowGroup] {
        var order: [String] = []
        var grouped: [String: [WindowInfo]] = [:]

        for window in windows {
            if grouped[window.ownerName] == nil {
                order.append(window.ownerName)
            }
            grouped[window.ownerName, default: []].append(window)
        }

        return order.compactMap { name in
            guard let wins = grouped[name] else { return nil }
            return WindowGroup(id: name, appName: name, windows: wins)
        }
    }
}
