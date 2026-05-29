struct ExecuteTextWatchActionRequest: UseCaseRequest, Sendable {
    let windowID: UInt32
    let pid: Int32
    let actions: [TextWatchActionDTO]

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard pid > 0 else {
            throw ValidationError.invalidPID
        }
        guard !actions.isEmpty else {
            throw ValidationError.emptyActionList
        }
        guard actions.count <= 16 else {
            throw ValidationError.tooManyActions
        }
        for action in actions {
            try action.validate()
        }
    }
}
