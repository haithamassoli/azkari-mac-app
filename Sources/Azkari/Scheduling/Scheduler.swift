import Foundation

/// Fires `onFire` every `intervalMinutes`. Implemented as a MainActor task loop
/// (rather than a `Timer`) so it composes cleanly with Swift 6 strict concurrency.
///
/// Restarting (e.g. on wake from sleep) resets the countdown to a full interval,
/// so the user never gets a burst of missed reminders.
@MainActor
@Observable
final class Scheduler {
    var intervalMinutes: Int = 30
    private(set) var isPaused = false

    /// Called on the main actor each time the interval elapses.
    var onFire: (() -> Void)?

    private var loopTask: Task<Void, Never>?

    func start() {
        stop()
        guard !isPaused else { return }
        let seconds = Double(max(1, intervalMinutes) * 60)
        loopTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(seconds))
                if Task.isCancelled { return }
                self?.onFire?()
            }
        }
    }

    func stop() {
        loopTask?.cancel()
        loopTask = nil
    }

    func restart() {
        start()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { stop() } else { start() }
    }

    func togglePause() {
        setPaused(!isPaused)
    }
}
