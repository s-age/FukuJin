protocol WindowBoundsRepositoryProtocol: Sendable {
    func getWindowBounds(_ windowID: UInt32) -> BoundingBox?
}
