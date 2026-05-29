import AppKit
import SwiftUI

@MainActor
final class SwiftUIWindowHostBridge<Content: View>: NSObject, NSWindowDelegate {
    private let config: WindowConfig
    private let content: @MainActor () -> Content
    private let onWillClose: (@MainActor () -> Void)?

    private var window: NSWindow?

    init(
        config: WindowConfig,
        content: @escaping @MainActor () -> Content,
        onWillClose: (@MainActor () -> Void)? = nil
    ) {
        self.config = config
        self.content = content
        self.onWillClose = onWillClose
        super.init()
    }

    func show() {
        if let window, window.isVisible {
            activateAndFocus(window)
            return
        }

        let hosting = NSHostingController(rootView: content())
        hosting.sizingOptions = []

        let window = makeWindow()
        window.contentViewController = hosting
        window.setContentSize(NSSize(width: config.size.width, height: config.size.height))
        window.delegate = self
        if config.centerOnShow { window.center() }
        self.window = window

        activateAndFocus(window)
    }

    /// Brings the window to front and makes it key — then re-asserts on the next runloop tick.
    /// When this window is opened from a `MenuBarExtra(.window)` item, that popover dismisses
    /// *after* `show()` returns and can momentarily steal key status back. Without the re-assert,
    /// the window is visible but not key, so the user's first click on a text field is consumed by
    /// re-activating the window instead of placing the caret — felt as focus "lag" on the first
    /// field clicked (e.g. the search field), while later fields focus instantly.
    private func activateAndFocus(_ window: NSWindow) {
        if config.activatesApp { NSApp.activate(ignoringOtherApps: true) }
        window.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak window] in
            guard let window else { return }
            if self.config.activatesApp { NSApp.activate(ignoringOtherApps: true) }
            window.makeKeyAndOrderFront(nil)
        }
    }

    func close() {
        window?.orderOut(nil)
        window = nil
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: config.size),
            styleMask: config.styleMask,
            backing: .buffered,
            defer: false
        )
        window.title = config.title
        window.isReleasedWhenClosed = false
        window.isOpaque = config.isOpaque
        if let color = config.backgroundColor { window.backgroundColor = color }
        window.hasShadow = config.hasShadow
        window.collectionBehavior = config.collectionBehavior
        if let level = config.level { window.level = level }
        return window
    }

    nonisolated func windowWillClose(_ notification: Notification) {
        MainActor.assumeIsolated {
            onWillClose?()
            window = nil
        }
    }
}
