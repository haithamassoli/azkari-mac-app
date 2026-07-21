import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            Text("ذكر")
                .font(.largeTitle.bold())

            Text("تطبيقٌ يعرض الأذكار بشكلٍ دوري في زاوية الشاشة.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("الإصدار ١٫٠")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("الأذكار المضمّنة من المأثور المشهور، ويمكنك تعديلها وإضافة أذكارك الخاصة.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
