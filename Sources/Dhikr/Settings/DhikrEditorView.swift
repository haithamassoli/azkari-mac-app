import SwiftUI
import Foundation

/// Sheet for adding a new dhikr or editing a custom one. Built-in items never
/// reach this view directly — they're duplicated into a new custom item first.
struct DhikrEditorView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var working: Dhikr
    private let isNew: Bool

    init(seed: Dhikr?, isNew: Bool) {
        _working = State(initialValue: seed ?? Dhikr(arabicText: "", category: .custom))
        self.isNew = isNew
    }

    private var canSave: Bool {
        !working.arabicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(app.prefs.language.tr(.sectionText)) {
                    TextField(app.prefs.language.tr(.arabicTextField), text: $working.arabicText, axis: .vertical)
                        .lineLimit(2...6)
                        .font(.title3)
                }

                Section(app.prefs.language.tr(.sectionOptionalDetails)) {
                    TextField(app.prefs.language.tr(.transliterationField), text: optionalBinding(\.transliteration))
                    TextField(app.prefs.language.tr(.translationField), text: optionalBinding(\.translation))
                    TextField(app.prefs.language.tr(.sourceField), text: optionalBinding(\.source))
                    Stepper(app.prefs.language.tr(.repeatCountLabel, working.repeatCount), value: $working.repeatCount, in: 1...1000)
                    Picker(app.prefs.language.tr(.categoryField), selection: $working.category) {
                        ForEach(DhikrCategory.allCases) { category in
                            Text(category.localizedName(app.prefs.language)).tag(category)
                        }
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Button(app.prefs.language.tr(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isNew ? app.prefs.language.tr(.add) : app.prefs.language.tr(.save)) { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canSave)
            }
            .padding(12)
        }
        .frame(width: 460, height: 440)
        .environment(\.layoutDirection, app.prefs.language.layoutDirection)
        .environment(\.locale, app.prefs.language.locale)
    }

    private func optionalBinding(_ keyPath: WritableKeyPath<Dhikr, String?>) -> Binding<String> {
        Binding(
            get: { working[keyPath: keyPath] ?? "" },
            set: { working[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
        )
    }

    private func save() {
        guard canSave else { return }
        if isNew {
            app.store.add(working)
        } else {
            app.store.update(working)
        }
        dismiss()
    }
}
