import AppKit
import SwiftUI

/// Owns the single reusable popup panel and drives presentation: positioning,
/// fade in/out, auto-dismiss (with hover-to-keep), and the appearance chime.
@MainActor
final class DhikrPanelController {
    private var panel: DhikrPanel?
    private var hosting: NSHostingView<AnyView>?
    private var currentModel: ToastModel?
    private var dismissTask: Task<Void, Never>?

    private let panelWidth: CGFloat = 340

    func present(_ dhikr: Dhikr, prefs: Preferences, sound: SoundPlayer) {
        dismissTask?.cancel()

        let duration = prefs.displayDuration
        let model = ToastModel(dhikr: dhikr, prefs: prefs)
        model.onClose = { [weak self] in self?.dismiss() }
        model.onComplete = { [weak self] in self?.scheduleAutoDismiss(after: 1.6) }
        model.onCountChanged = { [weak self] in self?.scheduleAutoDismiss(after: duration) }
        model.onHover = { [weak self] hovering in self?.hoverChanged(hovering, duration: duration) }
        currentModel = model

        let panel = ensurePanel()
        let root = AnyView(DhikrToastView(model: model))

        let host: NSHostingView<AnyView>
        if let hosting {
            hosting.rootView = root
            host = hosting
        } else {
            host = NSHostingView(rootView: root)
            hosting = host
            panel.contentView = host
        }
        host.layoutSubtreeIfNeeded()

        let fittingHeight = host.fittingSize.height
        let size = CGSize(width: panelWidth, height: max(80, fittingHeight))

        guard let screen = ScreenPositioning.targetScreen(prefs.screenMode) else { return }
        let frame = ScreenPositioning.frame(for: size, corner: prefs.corner, on: screen)

        let wasVisible = panel.isVisible && panel.alphaValue > 0.01
        panel.setFrame(frame, display: true)

        if wasVisible {
            panel.alphaValue = 1
            panel.orderFrontRegardless()
        } else {
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                panel.animator().alphaValue = 1
            }
        }

        sound.playChime(enabled: prefs.soundEnabled)
        scheduleAutoDismiss(after: duration)
    }

    func dismiss() {
        dismissTask?.cancel()
        guard let panel else { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.22
            panel.animator().alphaValue = 0
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(240))
            self?.panel?.orderOut(nil)
        }
    }

    // MARK: - Private

    private func ensurePanel() -> DhikrPanel {
        if let panel { return panel }
        let p = DhikrPanel()
        panel = p
        return p
    }

    private func scheduleAutoDismiss(after seconds: TimeInterval) {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            if Task.isCancelled { return }
            self?.dismiss()
        }
    }

    private func hoverChanged(_ hovering: Bool, duration: TimeInterval) {
        if hovering {
            dismissTask?.cancel()
        } else {
            scheduleAutoDismiss(after: max(2, duration * 0.4))
        }
    }
}
