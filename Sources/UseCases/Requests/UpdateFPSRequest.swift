struct UpdateFPSRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let fps: Double

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard (1.0...60.0).contains(fps) else { throw ValidationError.invalidFPS }
    }
}
