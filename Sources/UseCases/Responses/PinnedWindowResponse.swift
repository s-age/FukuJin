struct PinnedWindowResponse: Equatable, Sendable {
    let windowID: UInt32
    let ownerPID: Int32
    let ownerName: String
    let windowName: String
    let opacity: Double
    let fps: Double
    let scan: ScanConfigResponse

    init(from entity: PinnedWindow) {
        windowID = entity.window.id
        ownerPID = entity.window.ownerPID
        ownerName = entity.window.ownerName
        windowName = entity.window.windowName
        opacity = entity.opacity
        fps = entity.fps
        scan = ScanConfigResponse(from: entity.scan)
    }
}
