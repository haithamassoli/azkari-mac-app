import SwiftUI

/// View-model for one popup presentation. Holds the (per-presentation) tasbeeh
/// count and forwards user interactions to the controller via closures.
@MainActor
@Observable
final class ToastModel {
    let dhikr: Dhikr
    let fontSize: Double
    let showTransliteration: Bool
    let showTranslation: Bool
    let counterEnabled: Bool
    let language: AppLanguage

    var count: Int = 0
    var isComplete: Bool = false

    // Wired by DhikrPanelController.
    var onClose: () -> Void = {}
    var onComplete: () -> Void = {}
    var onCountChanged: () -> Void = {}
    var onHover: (Bool) -> Void = { _ in }

    init(dhikr: Dhikr, prefs: Preferences) {
        self.dhikr = dhikr
        self.fontSize = prefs.fontSize
        self.showTransliteration = prefs.showTransliteration
        self.showTranslation = prefs.showTranslation
        self.counterEnabled = prefs.counterEnabled
        self.language = prefs.language
    }

    var target: Int { max(1, dhikr.repeatCount) }
    var showsCounter: Bool { counterEnabled && dhikr.repeatCount > 1 }

    /// A tap on the card. With a counter it counts up; otherwise it dismisses.
    func tap() {
        guard showsCounter else { onClose(); return }
        guard !isComplete else { return }
        count += 1
        onCountChanged()
        if count >= target {
            isComplete = true
            onComplete()
        }
    }
}

/// The popup card: Arabic remembrance (RTL), optional transliteration/translation,
/// source, and a tasbeeh counter when the dhikr has a repeat count.
struct DhikrToastView: View {
    let model: ToastModel

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header

            Text(model.dhikr.arabicText)
                .font(.system(size: model.fontSize, weight: .medium))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)

            if model.showTransliteration, let t = model.dhikr.transliteration, !t.isEmpty {
                Text(t)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if model.showTranslation, let tr = model.dhikr.translation, !tr.isEmpty {
                Text(tr)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if model.showsCounter {
                counter
            }
        }
        .padding(18)
        .frame(width: 340)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { model.tap() }
        .onHover { model.onHover($0) }
        .environment(\.layoutDirection, model.language.layoutDirection)
        .environment(\.locale, model.language.locale)
    }

    // Source on the (RTL) leading/right edge; close button on the left.
    private var header: some View {
        HStack(spacing: 8) {
            if let source = model.dhikr.source, !source.isEmpty {
                Text(source)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Button(action: { model.onClose() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(model.language.tr(.close))
        }
    }

    @ViewBuilder private var counter: some View {
        VStack(spacing: 6) {
            if model.isComplete {
                Label(model.language.tr(.counterDone), systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Text("\(model.count) / \(model.target)")
                    .font(.title3.monospacedDigit().weight(.semibold))
                ProgressView(value: Double(model.count), total: Double(model.target))
                    .frame(width: 180)
                Text(model.language.tr(.tapToCount))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 2)
        .animation(.spring(duration: 0.25), value: model.count)
        .animation(.spring(duration: 0.25), value: model.isComplete)
    }
}
