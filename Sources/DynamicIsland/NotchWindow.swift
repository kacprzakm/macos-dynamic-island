import AppKit
import SwiftUI
import Combine

final class NotchWindow: NSPanel {
    private let model = IslandModel()
    private var cancellables = Set<AnyCancellable>()
    private var hoverTimer: Timer?
    private var outsideSince: Date?

    private let expandedSize = NSSize(width: 306, height: 242)
    private let collapseDelay: TimeInterval = 0.3

    init() {
        let screen = NotchWindow.targetScreen()
        super.init(
            contentRect: NSRect(origin: .zero, size: NotchWindow.collapsedSize(for: screen)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovableByWindowBackground = false
        hidesOnDeactivate = false

        let root = IslandView(model: model)
        contentView = NSHostingView(rootView: root)

        model.$isExpanded
            .removeDuplicates()
            .sink { [weak self] expanded in
                self?.apply(expanded: expanded, animated: true)
            }
            .store(in: &cancellables)

        apply(expanded: false, animated: false)
        startHoverTracking()
    }

    deinit { hoverTimer?.invalidate() }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    func reanchor() {
        apply(expanded: model.isExpanded, animated: false)
    }

    private func startHoverTracking() {
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.trackMouse()
        }
        RunLoop.main.add(timer, forMode: .common)
        hoverTimer = timer
    }

    private func trackMouse() {
        let mouse = NSEvent.mouseLocation
        let screen = NotchWindow.targetScreen()

        if model.isExpanded {
            let zone = frame(expanded: true, on: screen).insetBy(dx: -8, dy: -8)
            if zone.contains(mouse) {
                outsideSince = nil
            } else if let since = outsideSince {
                if Date().timeIntervalSince(since) >= collapseDelay { setExpanded(false) }
            } else {
                outsideSince = Date()
            }
        } else {
            let zone = frame(expanded: false, on: screen).insetBy(dx: -4, dy: -4)
            if zone.contains(mouse) { setExpanded(true) }
        }
    }

    private func setExpanded(_ value: Bool) {
        outsideSince = nil
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            model.isExpanded = value
        }
    }

    private func frame(expanded: Bool, on screen: NSScreen) -> NSRect {
        let size = expanded ? expandedSize : NotchWindow.collapsedSize(for: screen)
        let origin = NSPoint(
            x: screen.frame.midX - size.width / 2,
            y: screen.frame.maxY - size.height
        )
        return NSRect(origin: origin, size: size)
    }

    private func apply(expanded: Bool, animated: Bool) {
        let screen = NotchWindow.targetScreen()
        model.notchHeight = screen.safeAreaInsets.top
        let target = frame(expanded: expanded, on: screen)
        if animated {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.22
                ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
                animator().setFrame(target, display: true)
            }
        } else {
            setFrame(target, display: true)
        }
    }

    static func targetScreen() -> NSScreen {
        NSScreen.screens.first { $0.safeAreaInsets.top > 0 } ?? NSScreen.main ?? NSScreen.screens[0]
    }

    static func collapsedSize(for screen: NSScreen) -> NSSize {
        let width = notchWidth(for: screen)
        let height = max(screen.safeAreaInsets.top, 32)
        return NSSize(width: width > 0 ? width : 220, height: height)
    }

    static func notchWidth(for screen: NSScreen) -> CGFloat {
        let left = screen.auxiliaryTopLeftArea?.width ?? 0
        let right = screen.auxiliaryTopRightArea?.width ?? 0
        guard left > 0 || right > 0 else { return 0 }
        return screen.frame.width - left - right
    }
}
