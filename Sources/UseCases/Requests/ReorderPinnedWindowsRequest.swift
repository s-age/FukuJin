import Foundation

struct ReorderPinnedWindowsRequest: UseCaseRequest, Sendable {
    let order: [UInt32]

    func validate() throws {
        guard !order.isEmpty else {
            throw ValidationError.emptyPinOrder
        }
        guard order.count <= 1024 else {
            throw ValidationError.tooManyPinEntries
        }
        guard Set(order).count == order.count else {
            throw ValidationError.duplicatePinOrder
        }
        for id in order where id == 0 {
            throw ValidationError.invalidWindowID
        }
    }
}
