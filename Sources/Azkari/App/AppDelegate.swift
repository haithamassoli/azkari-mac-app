import AppKit

/// Thin lifecycle hook: starts the model once the app finishes launching.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppModel.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppModel.shared.scheduler.stop()
    }
}
