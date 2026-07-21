import SwiftUI
import Foundation

/// Identifies an editor presentation (add / edit / duplicate).
struct EditorRequest: Identifiable {
    let id = UUID()
    let seed: Dhikr?
    let isNew: Bool
}

/// The adhkar library: enable/disable, edit custom items, duplicate built-ins,
/// add new ones, and reset to defaults.
struct LibrarySettingsView: View {
    @Environment(AppModel.self) private var app
    @State private var editorRequest: EditorRequest?
    @State private var confirmReset = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(DhikrCategory.allCases) { category in
                    let items = app.store.adhkar.filter { $0.category == category }
                    if !items.isEmpty {
                        Section(category.arabicName) {
                            ForEach(items) { dhikr in
                                row(dhikr)
                            }
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button {
                    editorRequest = EditorRequest(seed: nil, isNew: true)
                } label: {
                    Label("إضافة ذِكر", systemImage: "plus")
                }
                Spacer()
                Button("إعادة التعيين…", role: .destructive) {
                    confirmReset = true
                }
            }
            .padding(12)
        }
        .sheet(item: $editorRequest) { request in
            DhikrEditorView(seed: request.seed, isNew: request.isNew)
                .environment(app)
        }
        .confirmationDialog("إعادة تعيين الأذكار", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("إعادة الأذكار الأصلية فقط", role: .destructive) {
                app.store.resetBuiltIns()
            }
            Button("إعادة كل شيء (يحذف أذكاري)", role: .destructive) {
                app.store.resetEverything()
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("يمكنك إعادة الأذكار الأصلية فقط، أو إعادة كل شيء وحذف أذكارك المضافة.")
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private func row(_ dhikr: Dhikr) -> some View {
        HStack(spacing: 10) {
            Toggle("", isOn: Binding(
                get: { dhikr.isEnabled },
                set: { app.store.setEnabled(dhikr.id, $0) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)

            VStack(alignment: .leading, spacing: 2) {
                Text(dhikr.arabicText)
                    .font(.system(size: 15))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if dhikr.isBuiltIn {
                        Text("أصلي").font(.caption2).foregroundStyle(.secondary)
                    }
                    if dhikr.repeatCount > 1 {
                        Text("×\(dhikr.repeatCount)").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 8)

            if dhikr.isBuiltIn {
                Button {
                    editorRequest = EditorRequest(seed: app.store.duplicateForEditing(dhikr), isNew: true)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .help("نسخ للتعديل")
            } else {
                Button {
                    editorRequest = EditorRequest(seed: dhikr, isNew: false)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
                .help("تعديل")

                Button {
                    app.store.delete(dhikr)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("حذف")
            }
        }
        .padding(.vertical, 2)
    }
}
