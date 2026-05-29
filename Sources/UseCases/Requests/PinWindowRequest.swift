struct PinWindowRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let ownerPID: Int32
    let ownerName: String
    let windowName: String
    let opacity: Double
    let fps: Double

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard (0.1...1.0).contains(opacity) else { throw ValidationError.invalidOpacity }
        guard (1.0...60.0).contains(fps) else { throw ValidationError.invalidFPS }
    }
}
