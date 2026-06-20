import SwiftUI
import AppKit

/// Contents of the menu-bar dropdown (Arabic).
struct MenuBarMenu: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        Button("أظهر ذِكرًا الآن") {
            app.showNextDhikr(manual: true)
        }
        .disabled(app.enabledAdhkar.isEmpty)

        if app.enabledAdhkar.isEmpty {
            Text("لا توجد أذكار مُفعَّلة")
        }

        Divider()

        Button(app.isPaused ? "استئناف التذكير" : "إيقاف التذكير مؤقتًا") {
            app.togglePause()
        }

        SettingsLink {
            Text("الإعدادات…")
        }

        Divider()

        Button("إنهاء أذكاري") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
