struct ActivatePinnedWindowRequest: UseCaseRequest, Sendable {
    let windowID: UInt32

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
    }
}
