import AppKit
import SwiftUI

/// First-run onboarding: one scrolling screen that walks the user through the
/// core choices — language, reminder interval, time-aware selection,
/// launch-at-login, and which adhkar to enable — and lets them preview a real
/// popup. It binds live to the shared `Preferences`/`DhikrStore`, so every
/// change applies immediately; there is no staging and no separate "apply".
/// Any dismissal (the button or the window's close box) completes onboarding.
struct OnboardingView: View {
    @Environment(AppModel.self) private var app
    let onDone: () -> Void

    private let intervalPresets = [15, 30, 60, 120]

    var body: some View {
        @Bindable var prefs = app.prefs
        let lang = prefs.language

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Language first, so the rest of the screen renders in the choice.
                Picker("", selection: $prefs.language) {
                    ForEach(AppLanguage.allCases) { Text($0.nativeName).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                header(lang)
                interval(lang)
                Toggle(lang.tr(.timeAware), isOn: $prefs.timeAwareEnabled)
                launchAtLogin(lang)
                adhkar(lang)
                actions(lang)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .environment(\.locale, lang.locale)
        .environment(\.layoutDirection, lang.layoutDirection)
        .onAppear { app.refreshLoginStatus() }
    }

    private func header(_ lang: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.tr(.onbWelcomeTitle)).font(.largeTitle.bold())
            Text(lang.tr(.onbWelcomeSubtitle)).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func interval(_ lang: AppLanguage) -> some View {
        @Bindable var prefs = app.prefs
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.tr(.onbIntervalQuestion)).font(.headline)
            HStack(spacing: 8) {
                ForEach(intervalPresets, id: \.self) { m in
                    Button(lang.tr(.onbMinutes, m)) {
                        prefs.intervalMinutes = m
                        app.applyInterval()
                    }
                    .buttonStyle(.bordered)
                    .tint(prefs.intervalMinutes == m ? .accentColor : .secondary)
                }
            }
            Stepper(lang.tr(.intervalEvery, prefs.intervalMinutes),
                    value: $prefs.intervalMinutes, in: 1...240)
                .onChange(of: prefs.intervalMinutes) { app.applyInterval() }
        }
    }

    @ViewBuilder
    private func launchAtLogin(_ lang: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(lang.tr(.launchAtLogin), isOn: Binding(
                get: { app.loginEnabled },
                set: { app.setLogin($0) }
            ))
            if app.loginRequiresApproval {
                HStack {
                    Text(lang.tr(.loginDisabledBySystem))
                        .font(.caption).foregroundStyle(.secondary)
                    Button(lang.tr(.openSystemSettings)) { app.openLoginSettings() }
                        .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func adhkar(_ lang: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.tr(.onbChooseAdhkar)).font(.headline)
            ForEach(DhikrCategory.allCases) { category in
                let items = app.store.adhkar.filter { $0.category == category }
                if !items.isEmpty {
                    Text(category.localizedName(lang))
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(.top, 4)
                    ForEach(items) { dhikr in
                        Toggle(isOn: Binding(
                            get: { dhikr.isEnabled },
                            set: { app.store.setEnabled(dhikr.id, $0) }
                        )) {
                            Text(dhikr.arabicText).font(.system(size: 15)).lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func actions(_ lang: AppLanguage) -> some View {
        Divider()
        HStack {
            Button(lang.tr(.previewNow)) { app.showNextDhikr(manual: true) }
                .disabled(app.enabledAdhkar.isEmpty)
            Spacer()
            Button(lang.tr(.onbStart)) { onDone() }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

/// Presents onboarding as a standalone window. The app is `LSUIElement`
/// (menu-bar-only, no dock icon and no ordinary window), so we flip the
/// activation policy to `.regular` while onboarding is up — giving it a
/// focusable window and a dock icon — then back to `.accessory` on close.
/// `onFinish` runs on any close (button or the window's X).
@MainActor
final class OnboardingWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init()
    }

    func show(app: AppModel) {
        if let window {
            NSApp.activate()
            window.makeKeyAndOrderFront(nil)
            return
        }
        let root = OnboardingView(onDone: { [weak self] in self?.window?.close() })
            .environment(app)
        let win = NSWindow(contentViewController: NSHostingController(rootView: root))
        win.title = app.prefs.language.tr(.appName)
        win.styleMask = [.titled, .closable]
        win.isReleasedWhenClosed = false   // we hold it; released when we drop the ref
        win.setContentSize(NSSize(width: 460, height: 620))
        win.center()
        win.delegate = self
        window = win

        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        win.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
        NSApp.setActivationPolicy(.accessory)
        onFinish()
    }
}
