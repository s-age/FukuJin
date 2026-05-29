struct PinnedWindowListResponse: Equatable, Sendable {
    let windows: [PinnedWindowResponse]
    let hasPinnedWindows: Bool

    static let empty = PinnedWindowListResponse(windows: [], hasPinnedWindows: false)

    private init(windows: [PinnedWindowResponse], hasPinnedWindows: Bool) {
        self.windows = windows
        self.hasPinnedWindows = hasPinnedWindows
    }

    init(from entity: PinnedWindowList) {
        self.windows = entity.windows.map(PinnedWindowResponse.init(from:))
        self.hasPinnedWindows = entity.hasPinnedWindows
    }

    var windowIDs: [UInt32] { windows.map(\.windowID) }

    subscript(id: UInt32) -> PinnedWindowResponse? { windows.first { $0.windowID == id } }
}
