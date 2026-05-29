struct RaiseWindowRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let pid: Int32

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
    }
}
