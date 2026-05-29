import Foundation

struct ScanTextRequest: UseCaseRequest, Sendable {
    struct Bounds: Sendable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double
    }

    let windowID: UInt32
    let imageID: UUID
    let bounds: Bounds
    let searchText: String

    func validate() throws {
        guard windowID > 0 else { throw ValidationError.invalidWindowID }
        guard !searchText.isEmpty else {
            throw ValidationError.emptySearchText
        }
        guard searchText.count <= 256 else {
            throw ValidationError.searchTextTooLong
        }
    }
}
