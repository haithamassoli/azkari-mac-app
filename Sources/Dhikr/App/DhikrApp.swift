import SwiftUI

@main
struct DhikrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let appModel = AppModel.shared

    var body: some Scene {
        MenuBarExtra(appModel.prefs.language.tr(.appName), systemImage: "moon.stars") {
            MenuBarMenu()
                .environment(appModel)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environment(appModel)
        }
    }
}
