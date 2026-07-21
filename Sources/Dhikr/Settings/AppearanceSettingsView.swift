import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var prefs = app.prefs

        Form {
            Section("الموضع") {
                Picker("زاوية الظهور", selection: $prefs.corner) {
                    ForEach(ScreenCorner.allCases) { corner in
                        Text(corner.arabicName).tag(corner)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("المدّة") {
                VStack(alignment: .leading) {
                    Text("مدّة الظهور: \(Int(prefs.displayDuration)) ثانية")
                    Slider(value: $prefs.displayDuration, in: 4...60, step: 1)
                }
            }

            Section("الخط والمحتوى") {
                VStack(alignment: .leading) {
                    Text("حجم الخط: \(Int(prefs.fontSize))")
                    Slider(value: $prefs.fontSize, in: 16...48, step: 1)
                }
                Toggle("إظهار النقحرة (حروف لاتينية)", isOn: $prefs.showTransliteration)
                Toggle("إظهار الترجمة", isOn: $prefs.showTranslation)
                Toggle("إظهار عدّاد التسبيح (اضغط للعدّ)", isOn: $prefs.counterEnabled)

                Text("سُبْحَانَ اللَّهِ وَبِحَمْدِهِ")
                    .font(.system(size: prefs.fontSize, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            }

            Section("الصوت") {
                Toggle("تشغيل صوت عند الظهور", isOn: $prefs.soundEnabled)
                Button("تجربة الصوت") { app.soundPlayer.playChime(enabled: true) }
            }

            Section {
                Button("معاينة التذكير الآن") { app.showNextDhikr(manual: true) }
                    .disabled(app.enabledAdhkar.isEmpty)
            }
        }
        .formStyle(.grouped)
    }
}
