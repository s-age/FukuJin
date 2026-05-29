struct OrderWindowBelowRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let relativeWindowID: UInt32

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard relativeWindowID > 0 else { throw ValidationError.invalidWindowID }
    }
}
