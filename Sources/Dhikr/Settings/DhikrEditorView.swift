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
                Section("النص") {
                    TextField("النص العربي", text: $working.arabicText, axis: .vertical)
                        .lineLimit(2...6)
                        .font(.title3)
                }

                Section("تفاصيل (اختياري)") {
                    TextField("النقحرة", text: optionalBinding(\.transliteration))
                    TextField("الترجمة", text: optionalBinding(\.translation))
                    TextField("المصدر", text: optionalBinding(\.source))
                    Stepper("عدد التكرار: \(working.repeatCount)", value: $working.repeatCount, in: 1...1000)
                    Picker("التصنيف", selection: $working.category) {
                        ForEach(DhikrCategory.allCases) { category in
                            Text(category.arabicName).tag(category)
                        }
                    }
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Button("إلغاء") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isNew ? "إضافة" : "حفظ") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canSave)
            }
            .padding(12)
        }
        .frame(width: 460, height: 440)
        .environment(\.layoutDirection, .rightToLeft)
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
