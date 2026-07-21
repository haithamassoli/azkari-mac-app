import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var prefs = app.prefs

        Form {
            Section(app.prefs.language.tr(.sectionReminders)) {
                Stepper(value: $prefs.intervalMinutes, in: 1...240) {
                    Text(app.prefs.language.tr(.intervalEvery, prefs.intervalMinutes))
                }
                .onChange(of: prefs.intervalMinutes) { app.applyInterval() }

                Toggle(app.prefs.language.tr(.pauseReminders), isOn: Binding(
                    get: { app.isPaused },
                    set: { newValue in if newValue != app.isPaused { app.togglePause() } }
                ))

                Picker(app.prefs.language.tr(.selectionMethod), selection: $prefs.selectionMode) {
                    ForEach(SelectionMode.allCases) { mode in
                        Text(mode.localizedName(app.prefs.language)).tag(mode)
                    }
                }

                Toggle(app.prefs.language.tr(.timeAware), isOn: $prefs.timeAwareEnabled)
            }

            Section(app.prefs.language.tr(.sectionDisplay)) {
                Picker(app.prefs.language.tr(.screenLabel), selection: $prefs.screenMode) {
                    ForEach(ScreenMode.allCases) { mode in
                        Text(mode.localizedName(app.prefs.language)).tag(mode)
                    }
                }
            }

            Section(app.prefs.language.tr(.sectionStartup)) {
                Toggle(app.prefs.language.tr(.launchAtLogin), isOn: Binding(
                    get: { app.loginEnabled },
                    set: { app.setLogin($0) }
                ))

                if app.loginRequiresApproval {
                    HStack {
                        Text(app.prefs.language.tr(.loginDisabledBySystem))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(app.prefs.language.tr(.openSystemSettings)) { app.openLoginSettings() }
                            .font(.caption)
                    }
                }
            }

            Section(app.prefs.language.tr(.languageLabel)) {
                Picker(app.prefs.language.tr(.languageLabel), selection: $prefs.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.nativeName).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
        .formStyle(.grouped)
        .onAppear { app.refreshLoginStatus() }
    }
}
