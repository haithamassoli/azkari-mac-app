import SwiftUI
import AppKit

/// Contents of the menu-bar dropdown (Arabic).
struct MenuBarMenu: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        Button(app.prefs.language.tr(.menuShowNow)) {
            app.showNextDhikr(manual: true)
        }
        .disabled(app.enabledAdhkar.isEmpty)

        if app.enabledAdhkar.isEmpty {
            Text(app.prefs.language.tr(.menuNoneEnabled))
        }

        Divider()

        Button(app.isPaused ? app.prefs.language.tr(.resumeReminders) : app.prefs.language.tr(.pauseReminders)) {
            app.togglePause()
        }

        SettingsLink {
            Text(app.prefs.language.tr(.menuSettings))
        }

        Divider()

        Button(app.prefs.language.tr(.menuQuit)) {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
