struct UpdateLaunchAtLoginRequest: UseCaseRequest, Sendable {
    let enabled: Bool

    func validate() throws {}
}
