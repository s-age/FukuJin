import Foundation

struct PinnedWindowList: Equatable, Sendable {
    private(set) var windows: [PinnedWindow]   // array order == z-order (top of list = frontmost)

    static let empty = PinnedWindowList(windows: [])

    var hasPinnedWindows: Bool { !windows.isEmpty }
    var windowIDs: [UInt32] { windows.map(\.id) }

    subscript(id: UInt32) -> PinnedWindow? { windows.first { $0.id == id } }

    func isPinned(_ id: UInt32) -> Bool { self[id] != nil }

    func pinning(_ window: WindowInfo, seed: OverlayConfig) -> PinnedWindowList {
        guard self[window.id] == nil else { return self }
        var copy = self
        copy.windows.append(.create(window: window, seed: seed))
        return copy
    }

    func unpinning(_ id: UInt32) -> PinnedWindowList {
        var copy = self
        copy.windows.removeAll { $0.id == id }
        return copy
    }

    func unpinningAll() -> PinnedWindowList { .empty }

    func mutatingWindow(_ id: UInt32, transform: (PinnedWindow) throws -> PinnedWindow) throws -> PinnedWindowList {
        guard let index = windows.firstIndex(where: { $0.id == id }) else {
            throw DomainError.windowNotFound(windowID: id)
        }
        var copy = self
        copy.windows[index] = try transform(copy.windows[index])
        return copy
    }

    func pruning(keeping activeIDs: Set<UInt32>) -> PinnedWindowList {
        var copy = self
        copy.windows.removeAll { !activeIDs.contains($0.id) }
        return copy
    }

    // Preserve old reordering semantics: take newOrder (dedup, only existing), then append any
    // windows not mentioned in their existing relative order.
    func reordering(_ newOrder: [UInt32]) -> PinnedWindowList {
        var remaining = windows
        var result: [PinnedWindow] = []
        for id in newOrder {
            if let index = remaining.firstIndex(where: { $0.id == id }) {
                result.append(remaining.remove(at: index))
            }
        }
        result.append(contentsOf: remaining)
        var copy = self
        copy.windows = result
        return copy
    }
}
