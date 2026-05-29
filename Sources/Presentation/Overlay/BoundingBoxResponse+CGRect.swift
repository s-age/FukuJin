import CoreGraphics
import Foundation

extension CGRect {
    init(_ box: BoundingBoxResponse) {
        self.init(x: box.x, y: box.y, width: box.width, height: box.height)
    }
}
