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
        @Bindable var prefs = app.prefs
        VStack(spacing: 0) {
            Toggle(app.prefs.language.tr(.adhkarInEnglish), isOn: $prefs.adhkarInEnglish)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            Divider()
            List {
                ForEach(DhikrCategory.allCases) { category in
                    let items = app.store.adhkar.filter { $0.category == category }
                    if !items.isEmpty {
                        Section(category.localizedName(app.prefs.language)) {
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
                    Label(app.prefs.language.tr(.addDhikr), systemImage: "plus")
                }
                Spacer()
                Button(app.prefs.language.tr(.resetEllipsis), role: .destructive) {
                    confirmReset = true
                }
            }
            .padding(12)
        }
        .sheet(item: $editorRequest) { request in
            DhikrEditorView(seed: request.seed, isNew: request.isNew)
                .environment(app)
        }
        .confirmationDialog(app.prefs.language.tr(.resetTitle), isPresented: $confirmReset, titleVisibility: .visible) {
            Button(app.prefs.language.tr(.resetBuiltInsOnly), role: .destructive) {
                app.store.resetBuiltIns()
            }
            Button(app.prefs.language.tr(.resetEverything), role: .destructive) {
                app.store.resetEverything()
            }
            Button(app.prefs.language.tr(.cancel), role: .cancel) {}
        } message: {
            Text(app.prefs.language.tr(.resetMessage))
        }
        .environment(\.layoutDirection, app.prefs.language.layoutDirection)
        .environment(\.locale, app.prefs.language.locale)
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
                Text(dhikr.displayText(english: app.prefs.adhkarInEnglish))
                    .font(.system(size: 15))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if dhikr.isBuiltIn {
                        Text(app.prefs.language.tr(.builtInBadge)).font(.caption2).foregroundStyle(.secondary)
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
                .help(app.prefs.language.tr(.duplicateToEdit))
            } else {
                Button {
                    editorRequest = EditorRequest(seed: dhikr, isNew: false)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.borderless)
                .help(app.prefs.language.tr(.edit))

                Button {
                    app.store.delete(dhikr)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help(app.prefs.language.tr(.delete))
            }
        }
        .padding(.vertical, 2)
    }
}
