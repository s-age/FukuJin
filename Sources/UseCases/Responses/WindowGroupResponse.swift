struct WindowGroupResponse: Equatable, Sendable {
    let appName: String
    let windows: [WindowInfoResponse]

    init(from entity: WindowGroup) {
        self.appName = entity.appName
        self.windows = entity.windows.map { WindowInfoResponse(from: $0) }
    }

    init(appName: String, windows: [WindowInfoResponse]) {
        self.appName = appName
        self.windows = windows
    }
}
