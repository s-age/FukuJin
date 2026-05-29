import AppKit
import CoreGraphics
import QuartzCore

/// Image view that accepts the activating ("first") mouse click. Overlay windows belong to an
/// `.accessory` app and float above other apps, so without this the first click on an inactive
/// overlay is swallowed as the app-activation click and never reaches `mouseDown`. Hover still
/// works (its tracking area is `.activeAlways`), which is why the overlay looks alive yet ignores
/// clicks until this returns `true`.
private final class FirstMouseImageView: NSImageView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

final class OverlayWindow: NSWindow {
    let targetWindowID: UInt32
    private let imageView: NSImageView
    private let resolver: any CapturedImageResolverProtocol
    private var trackingArea: NSTrackingArea?
    private var highlightLayers: [CAShapeLayer] = []

    /// Primary-screen height used to flip CoreGraphics' top-left origin into AppKit's bottom-left.
    /// Cached because every frame would otherwise re-query `NSScreen`; invalidated only when the
    /// screen configuration changes (monitor plugged/unplugged, resolution change).
    private var primaryScreenHeight: CGFloat
    private var screenParamsObserver: (any NSObjectProtocol)?

    var inactiveOpacity: CGFloat = 0.5 {
        didSet { applyOpacity(inactiveOpacity) }
    }

    var onClicked: ((UInt32) -> Void)?

    init(
        targetWindowID: UInt32,
        initialFrame: CaptureResponse,
        resolver: any CapturedImageResolverProtocol
    ) {
        self.targetWindowID = targetWindowID
        self.imageView = FirstMouseImageView()
        self.resolver = resolver

        let initialHeight = Self.currentPrimaryScreenHeight() ?? 0
        self.primaryScreenHeight = initialHeight

        let nsRect = Self.cgRectToNS(CGRect(initialFrame.image.bounds), primaryHeight: initialHeight)

        super.init(
            contentRect: nsRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        isReleasedWhenClosed = false
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 8
        contentView?.layer?.masksToBounds = true
        contentView?.layer?.borderWidth = 2
        contentView?.layer?.borderColor = NSColor.systemBlue.withAlphaComponent(0.5).cgColor

        imageView.frame = contentView!.bounds
        imageView.autoresizingMask = [.width, .height]
        imageView.imageScaling = .scaleAxesIndependently
        imageView.wantsLayer = true
        imageView.layer?.contentsGravity = .resize
        contentView?.addSubview(imageView)

        applyOpacity(inactiveOpacity)
        setupTrackingArea()
        observeScreenParameters()
        updateFrame(initialFrame)
    }

    func updateFrame(_ response: CaptureResponse) {
        let target = Self.cgRectToNS(CGRect(response.image.bounds), primaryHeight: primaryScreenHeight)
        // Skip the setFrame round-trip when nothing moved — overlays update every captured frame
        // but the target window's geometry only changes when the user drags or resizes it.
        if target != frame {
            setFrame(target, display: false)
        }
        guard let cgImage = resolver.resolve(response.image) else { return }
        imageView.layer?.contents = cgImage
    }

    private func observeScreenParameters() {
        screenParamsObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.primaryScreenHeight = Self.currentPrimaryScreenHeight() ?? 0
            }
        }
    }

    func setHighlights(_ boundingBoxes: [BoundingBoxResponse]) {
        guard let layer = contentView?.layer else { return }

        // Grow the pool to cover the requested count; reuse existing layers across ticks
        // instead of tearing down and rebuilding every sublayer.
        while highlightLayers.count < boundingBoxes.count {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = NSColor.yellow.cgColor
            shapeLayer.lineWidth = 3
            shapeLayer.zPosition = 100
            layer.addSublayer(shapeLayer)
            highlightLayers.append(shapeLayer)
        }

        let w = layer.bounds.width
        let h = layer.bounds.height
        for (index, shapeLayer) in highlightLayers.enumerated() {
            guard index < boundingBoxes.count else {
                shapeLayer.isHidden = true
                continue
            }
            let box = boundingBoxes[index]
            let x = box.x * w
            let y = box.y * h
            let lineWidth = box.width * w
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + lineWidth, y: y))
            shapeLayer.path = path
            shapeLayer.isHidden = false
        }
    }

    func teardown() {
        onClicked = nil
        if let observer = screenParamsObserver {
            NotificationCenter.default.removeObserver(observer)
            screenParamsObserver = nil
        }
        orderOut(nil)
    }

    override func mouseEntered(with event: NSEvent) {
        applyOpacity(1.0)
    }

    override func mouseExited(with event: NSEvent) {
        applyOpacity(inactiveOpacity)
    }

    override func mouseDown(with event: NSEvent) {
        onClicked?(targetWindowID)
    }

    private func setupTrackingArea() {
        guard let view = contentView else { return }
        let area = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(area)
        trackingArea = area
    }

    private func applyOpacity(_ value: CGFloat) {
        imageView.alphaValue = value
        contentView?.layer?.borderColor = NSColor.systemBlue.withAlphaComponent(0.5 * value).cgColor
    }

    private static func currentPrimaryScreenHeight() -> CGFloat? {
        NSScreen.screens.first?.frame.height
    }

    static func cgRectToNS(_ cgRect: CGRect, primaryHeight: CGFloat) -> NSRect {
        NSRect(
            x: cgRect.origin.x,
            y: primaryHeight - cgRect.origin.y - cgRect.height,
            width: cgRect.width,
            height: cgRect.height
        )
    }
}
