import SwiftUI

struct AboutView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            Text(app.prefs.language.tr(.appName))
                .font(.largeTitle.bold())

            Text(app.prefs.language.tr(.aboutTagline))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text(app.prefs.language.tr(.aboutVersion))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(app.prefs.language.tr(.aboutBody))
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, app.prefs.language.layoutDirection)
        .environment(\.locale, app.prefs.language.locale)
    }
}
