struct UpdateOpacityRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let opacity: Double

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard (0.1...1.0).contains(opacity) else { throw ValidationError.invalidOpacity }
    }
}
