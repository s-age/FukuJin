struct GetAppIconRequest: UseCaseRequest, Sendable {
    let bundleIdentifier: String?
    let localizedName: String?

    func validate() throws {
        guard bundleIdentifier != nil || localizedName != nil else {
            throw ValidationError.missingAppIdentifier
        }
        if let bundleIdentifier, bundleIdentifier.count > 256 {
            throw ValidationError.bundleIdentifierTooLong
        }
        if let localizedName, localizedName.count > 256 {
            throw ValidationError.localizedNameTooLong
        }
    }
}
