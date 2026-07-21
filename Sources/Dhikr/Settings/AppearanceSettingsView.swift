import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var prefs = app.prefs

        Form {
            Section(app.prefs.language.tr(.sectionPosition)) {
                Picker(app.prefs.language.tr(.cornerLabel), selection: $prefs.corner) {
                    ForEach(ScreenCorner.allCases) { corner in
                        Text(corner.localizedName(app.prefs.language)).tag(corner)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(app.prefs.language.tr(.sectionDuration)) {
                VStack(alignment: .leading) {
                    Text(app.prefs.language.tr(.displayDurationSecs, Int(prefs.displayDuration)))
                    Slider(value: $prefs.displayDuration, in: 4...60, step: 1)
                }
            }

            Section(app.prefs.language.tr(.sectionFontContent)) {
                VStack(alignment: .leading) {
                    Text(app.prefs.language.tr(.fontSizeLabel, Int(prefs.fontSize)))
                    Slider(value: $prefs.fontSize, in: 16...48, step: 1)
                }
                Toggle(app.prefs.language.tr(.showTransliteration), isOn: $prefs.showTransliteration)
                Toggle(app.prefs.language.tr(.showTranslation), isOn: $prefs.showTranslation)
                Toggle(app.prefs.language.tr(.showCounter), isOn: $prefs.counterEnabled)

                Text("سُبْحَانَ اللَّهِ وَبِحَمْدِهِ")
                    .font(.system(size: prefs.fontSize, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            }

            Section(app.prefs.language.tr(.sectionSound)) {
                Toggle(app.prefs.language.tr(.playSoundOnShow), isOn: $prefs.soundEnabled)
                Button(app.prefs.language.tr(.testSound)) { app.soundPlayer.playChime(enabled: true) }
            }

            Section {
                Button(app.prefs.language.tr(.previewNow)) { app.showNextDhikr(manual: true) }
                    .disabled(app.enabledAdhkar.isEmpty)
            }
        }
        .formStyle(.grouped)
    }
}
