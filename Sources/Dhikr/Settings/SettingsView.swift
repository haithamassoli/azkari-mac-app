import SwiftUI

/// Host for the settings tabs. Forced right-to-left for the Arabic UI.
struct SettingsView: View {
    @Environment(AppModel.self) private var app
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label(app.prefs.language.tr(.tabGeneral), systemImage: "gearshape") }
            AppearanceSettingsView()
                .tabItem { Label(app.prefs.language.tr(.tabAppearance), systemImage: "paintbrush") }
            LibrarySettingsView()
                .tabItem { Label(app.prefs.language.tr(.tabLibrary), systemImage: "book") }
            AboutView()
                .tabItem { Label(app.prefs.language.tr(.tabAbout), systemImage: "info.circle") }
        }
        .frame(width: 540, height: 500)
        .environment(\.layoutDirection, app.prefs.language.layoutDirection)
        .environment(\.locale, app.prefs.language.locale)
    }
}
