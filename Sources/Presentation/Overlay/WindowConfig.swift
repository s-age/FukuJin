import AppKit

@MainActor
struct WindowConfig {
    let title: String
    let size: CGSize
    let styleMask: NSWindow.StyleMask
    let level: NSWindow.Level?
    let isOpaque: Bool
    let backgroundColor: NSColor?
    let hasShadow: Bool
    let collectionBehavior: NSWindow.CollectionBehavior
    let activatesApp: Bool
    let centerOnShow: Bool

    private init(
        title: String,
        size: CGSize,
        styleMask: NSWindow.StyleMask,
        level: NSWindow.Level?,
        isOpaque: Bool,
        backgroundColor: NSColor?,
        hasShadow: Bool,
        collectionBehavior: NSWindow.CollectionBehavior,
        activatesApp: Bool,
        centerOnShow: Bool
    ) {
        self.title = title
        self.size = size
        self.styleMask = styleMask
        self.level = level
        self.isOpaque = isOpaque
        self.backgroundColor = backgroundColor
        self.hasShadow = hasShadow
        self.collectionBehavior = collectionBehavior
        self.activatesApp = activatesApp
        self.centerOnShow = centerOnShow
    }

    static func standardPanel(title: String, size: CGSize) -> WindowConfig {
        WindowConfig(
            title: title,
            size: size,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            level: nil,
            isOpaque: true,
            backgroundColor: nil,
            hasShadow: true,
            collectionBehavior: [],
            activatesApp: true,
            centerOnShow: true
        )
    }

    static func floatingSplash(size: CGSize) -> WindowConfig {
        WindowConfig(
            title: "",
            size: size,
            styleMask: [.borderless, .fullSizeContentView],
            level: .floating,
            isOpaque: false,
            backgroundColor: .clear,
            hasShadow: true,
            collectionBehavior: [.canJoinAllSpaces, .stationary, .ignoresCycle],
            activatesApp: false,
            centerOnShow: true
        )
    }
}
