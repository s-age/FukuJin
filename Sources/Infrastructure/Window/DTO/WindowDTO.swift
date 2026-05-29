import Foundation

struct WindowDTO: Sendable {
    let windowID: UInt32
    let ownerPID: Int32
    let ownerName: String
    let windowName: String
}
