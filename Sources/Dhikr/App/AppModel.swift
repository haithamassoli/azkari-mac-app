import SwiftUI
import AppKit

/// Root coordinator. Owns the preferences, store, scheduler, selector, sound,
/// and panel controller, and wires them together. A single shared instance is
/// used so the SwiftUI scenes and the AppDelegate refer to the same object.
@MainActor
@Observable
final class AppModel {
    static let shared = AppModel()

    let prefs = Preferences()
    let store = DhikrStore()
    let scheduler = Scheduler()
    let panelController = DhikrPanelController()
    let soundPlayer = SoundPlayer()
    let selector = DhikrSelector()

    private(set) var loginEnabled = false
    private(set) var loginRequiresApproval = false

    private var started = false
    private var wakeObserver: (any NSObjectProtocol)?

    private init() {}

    /// Called from `applicationDidFinishLaunching`.
    func start() {
        guard !started else { return }
        started = true

        store.load()
        scheduler.intervalMinutes = prefs.intervalMinutes
        scheduler.onFire = { [weak self] in self?.showNextDhikr() }
        scheduler.start()
        observeWake()
        refreshLoginStatus()
    }

    // MARK: - Adhkar

    var enabledAdhkar: [Dhikr] { store.adhkar.filter { $0.isEnabled } }

    func showNextDhikr(manual: Bool = false) {
        let pool = enabledAdhkar
        guard !pool.isEmpty else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        guard let dhikr = selector.next(from: pool,
                                        mode: prefs.selectionMode,
                                        timeAware: prefs.timeAwareEnabled,
                                        hour: hour) else { return }
        panelController.present(dhikr, prefs: prefs, sound: soundPlayer)
    }

    // MARK: - Scheduling

    var isPaused: Bool { scheduler.isPaused }

    func togglePause() {
        if scheduler.isPaused {
            scheduler.intervalMinutes = prefs.intervalMinutes
            scheduler.setPaused(false)
        } else {
            scheduler.setPaused(true)
        }
    }

    /// Re-applies the interval and restarts the countdown (call when it changes).
    func applyInterval() {
        scheduler.intervalMinutes = prefs.intervalMinutes
        scheduler.restart()
    }

    // MARK: - Launch at login

    func refreshLoginStatus() {
        loginEnabled = LoginItem.isEnabled
        loginRequiresApproval = LoginItem.requiresApproval
    }

    func setLogin(_ enabled: Bool) {
        try? LoginItem.setEnabled(enabled)
        refreshLoginStatus()
    }

    func openLoginSettings() {
        LoginItem.openSystemSettings()
    }

    // MARK: - Sleep / wake

    private func observeWake() {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { _ in
            // Avoid capturing `self` in this @Sendable closure; hop to the main
            // actor and use the shared instance. Restart resets to a full
            // interval so there's no burst of missed reminders after waking.
            Task { @MainActor in AppModel.shared.scheduler.restart() }
        }
    }
}
