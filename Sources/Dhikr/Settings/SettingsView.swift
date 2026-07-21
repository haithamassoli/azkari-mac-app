import SwiftUI

/// Host for the settings tabs. Forced right-to-left for the Arabic UI.
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("عام", systemImage: "gearshape") }
            AppearanceSettingsView()
                .tabItem { Label("المظهر", systemImage: "paintbrush") }
            LibrarySettingsView()
                .tabItem { Label("الأذكار", systemImage: "book") }
            AboutView()
                .tabItem { Label("حول", systemImage: "info.circle") }
        }
        .frame(width: 540, height: 500)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
