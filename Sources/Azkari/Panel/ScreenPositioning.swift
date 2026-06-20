import AppKit

/// Helpers for choosing the target display and computing the popup's frame
/// within a screen's `visibleFrame` (which already excludes the menu bar and
/// Dock, and clears the notch on notched Macs).
enum ScreenPositioning {
    static func targetScreen(_ mode: ScreenMode) -> NSScreen? {
        switch mode {
        case .withCursor:
            let location = NSEvent.mouseLocation
            return NSScreen.screens.first { NSMouseInRect(location, $0.frame, false) }
                ?? NSScreen.main
                ?? NSScreen.screens.first
        case .main:
            return NSScreen.main ?? NSScreen.screens.first
        }
    }

    static func frame(for size: CGSize,
                      corner: ScreenCorner,
                      on screen: NSScreen,
                      inset: CGFloat = 16) -> NSRect {
        let vf = screen.visibleFrame  // AppKit coords: origin bottom-left
        let x: CGFloat
        let y: CGFloat
        switch corner {
        case .topLeft:
            x = vf.minX + inset
            y = vf.maxY - size.height - inset
        case .topRight:
            x = vf.maxX - size.width - inset
            y = vf.maxY - size.height - inset
        case .bottomLeft:
            x = vf.minX + inset
            y = vf.minY + inset
        case .bottomRight:
            x = vf.maxX - size.width - inset
            y = vf.minY + inset
        }
        return NSRect(x: x, y: y, width: size.width, height: size.height)
    }
}
