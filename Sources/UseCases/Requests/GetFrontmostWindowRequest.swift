struct GetFrontmostWindowRequest: UseCaseRequest, Sendable {
    let ownerPID: Int32

    func validate() throws {}
}
