import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        @Bindable var prefs = app.prefs

        Form {
            Section("التذكير") {
                Stepper(value: $prefs.intervalMinutes, in: 1...240) {
                    Text("الفاصل الزمني: كل \(prefs.intervalMinutes) دقيقة")
                }
                .onChange(of: prefs.intervalMinutes) { app.applyInterval() }

                Toggle("إيقاف التذكير مؤقتًا", isOn: Binding(
                    get: { app.isPaused },
                    set: { newValue in if newValue != app.isPaused { app.togglePause() } }
                ))

                Picker("طريقة الاختيار", selection: $prefs.selectionMode) {
                    ForEach(SelectionMode.allCases) { mode in
                        Text(mode.arabicName).tag(mode)
                    }
                }

                Toggle("الاختيار حسب وقت اليوم (صباح/مساء)", isOn: $prefs.timeAwareEnabled)
            }

            Section("العرض") {
                Picker("الشاشة", selection: $prefs.screenMode) {
                    ForEach(ScreenMode.allCases) { mode in
                        Text(mode.arabicName).tag(mode)
                    }
                }
            }

            Section("بدء التشغيل") {
                Toggle("التشغيل عند تسجيل الدخول", isOn: Binding(
                    get: { app.loginEnabled },
                    set: { app.setLogin($0) }
                ))

                if app.loginRequiresApproval {
                    HStack {
                        Text("التشغيل عند الدخول مُعطَّل من إعدادات النظام.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("فتح إعدادات النظام") { app.openLoginSettings() }
                            .font(.caption)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { app.refreshLoginStatus() }
    }
}
