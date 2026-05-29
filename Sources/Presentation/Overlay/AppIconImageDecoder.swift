import AppKit
import SwiftUI

/// Decodes raw PNG icon bytes (`AppIconResponse.pngData`) into a SwiftUI `Image`.
///
/// Lives in the `Overlay/` AppKit zone because PNG `Data` → `Image` decoding requires
/// `NSImage`, which `Feature/` SwiftUI views may not import (`arch-presentation`). The
/// capability is injected into ViewModels as a `@Sendable (Data) -> Image?` closure from
/// the DI container — the same pattern used for the captured-image resolver.
enum AppIconImageDecoder {
    static let decode: @Sendable (Data) -> Image? = { data in
        NSImage(data: data).map { Image(nsImage: $0) }
    }
}
