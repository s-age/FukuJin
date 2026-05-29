struct SyncOverlaysRequest: UseCaseRequest, Sendable {
    /// The pid of the app that just activated, when this sync is activation-driven; `nil` for a
    /// pin-state change (pin/unpin/reorder/opacity/fps).
    let activationPID: Int32?

    func validate() throws {}
}
