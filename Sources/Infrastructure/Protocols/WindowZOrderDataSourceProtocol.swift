import Foundation

protocol WindowZOrderDataSourceProtocol: Sendable {
    func orderWindow(_ windowID: UInt32, below relativeWindowID: UInt32)
}
