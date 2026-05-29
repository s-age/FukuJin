struct UpdateDefaultConfigRequest: UseCaseRequest, Sendable {
    let opacity: Double?
    let fps: Double?

    func validate() throws {
        if let opacity {
            guard opacity >= 0.1, opacity <= 1.0 else { throw ValidationError.invalidOpacity }
        }
        if let fps {
            guard fps >= 1, fps <= 60 else { throw ValidationError.invalidFPS }
        }
    }
}
