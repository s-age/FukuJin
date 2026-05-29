import Foundation

struct CapturedImageRefResponse: Equatable, Sendable {
    let snapshotID: UUID?
    let windowID: UInt32
    let bounds: BoundingBoxResponse
}

extension CapturedImageRefResponse {
    init(from image: CapturedImageRef) {
        let snapshotID: UUID? = switch image.resolution {
        case .streaming: nil
        case .oneShot(let id): id
        }
        self.init(
            snapshotID: snapshotID,
            windowID: image.windowID,
            bounds: BoundingBoxResponse(from: image.bounds)
        )
    }
}
