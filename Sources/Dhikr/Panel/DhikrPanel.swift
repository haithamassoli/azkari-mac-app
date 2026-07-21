import AppKit

/// Borderless, non-activating floating panel used for the corner popup.
///
/// `.nonactivatingPanel` is the key bit: the panel can show (and receive a
/// click/hover) without activating the app or stealing key focus, so the user
/// keeps typing in whatever app they were using.
@MainActor
final class DhikrPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 160),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        isMovableByWindowBackground = false
        hidesOnDeactivate = false          // stay visible while our app is inactive
        isReleasedWhenClosed = false       // we reuse the panel
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        animationBehavior = .none          // fades are driven manually
    }

    override var canBecomeKey: Bool { true }   // only if a control needs it (none do)
    override var canBecomeMain: Bool { false }
}
