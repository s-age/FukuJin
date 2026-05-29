import SwiftUI

struct AppIcon: View {
    let image: Image?
    let size: CGFloat

    var body: some View {
        if let image {
            image
                .resizable()
                .frame(width: size, height: size)
        }
    }
}
