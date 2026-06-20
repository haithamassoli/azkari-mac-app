import AppKit

/// Plays a gentle chime when a popup appears.
///
/// Uses a bundled `chime.caf` if present, otherwise a built-in macOS system
/// sound, otherwise the system beep. v1 ships without a custom file, so the
/// system sound is used by default.
@MainActor
final class SoundPlayer {
    private var sound: NSSound?

    func playChime(enabled: Bool) {
        guard enabled else { return }

        if let url = Bundle.main.url(forResource: "chime", withExtension: "caf"),
           let bundled = NSSound(contentsOf: url, byReference: true) {
            play(bundled)
        } else if let system = NSSound(named: NSSound.Name("Glass")) {
            play(system)
        } else {
            NSSound.beep()
        }
    }

    private func play(_ sound: NSSound) {
        // Retain so it isn't deallocated mid-playback.
        self.sound = sound
        sound.stop()
        sound.play()
    }
}
