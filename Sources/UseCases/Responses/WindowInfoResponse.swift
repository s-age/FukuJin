struct WindowInfoResponse: Equatable, Sendable {
    let id: UInt32
    let ownerPID: Int32
    let ownerName: String
    let windowName: String

    init(from entity: WindowInfo) {
        self.id = entity.id
        self.ownerPID = entity.ownerPID
        self.ownerName = entity.ownerName
        self.windowName = entity.windowName
    }
}
