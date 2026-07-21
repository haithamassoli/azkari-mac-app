import Foundation

/// Loads, persists, and mutates the list of adhkar.
///
/// - Built-in items are seeded from the bundled `adhkar.json` on first launch.
/// - The source of truth thereafter is a JSON file in Application Support.
/// - New built-ins shipped in later versions are merged in (by ID) without
///   duplicating or clobbering the user's enable/disable choices.
/// - Built-in items are read-only: their text cannot be edited and "deleting"
///   one only disables it (so a seed-merge won't resurrect it).
@MainActor
@Observable
final class DhikrStore {
    private(set) var adhkar: [Dhikr] = []

    private let fileURL: URL
    private let defaults = UserDefaults.standard
    private var saveTask: Task<Void, Never>?

    init() {
        let base = (try? FileManager.default.url(for: .applicationSupportDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: true))
            ?? URL(fileURLWithPath: NSHomeDirectory())
        let dir = base.appendingPathComponent("Dhikr", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("adhkar.json")
    }

    // MARK: - Loading & seeding

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let items = try? JSONDecoder().decode([Dhikr].self, from: data),
           !items.isEmpty {
            adhkar = items
            mergeNewBuiltIns()
        } else {
            let (version, seed) = Self.loadSeed()
            adhkar = seed
            defaults.set(version, forKey: DefaultsKeys.builtInSeedVersion)
            saveNow()
        }
        sortInPlace()
    }

    /// Reads the bundled seed file and maps it to `Dhikr` values (built-in, enabled).
    static func loadSeed() -> (version: Int, adhkar: [Dhikr]) {
        guard let url = Bundle.main.url(forResource: "adhkar", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(SeedFile.self, from: data) else {
            return (0, [])
        }
        let items = file.adhkar.enumerated().map { index, s in
            Dhikr(id: s.id,
                  arabicText: s.arabicText,
                  transliteration: s.transliteration,
                  translation: s.translation,
                  source: s.source,
                  repeatCount: s.repeatCount ?? 1,
                  category: s.category,
                  isEnabled: s.category == .general, // ponytail: only General on by default; rest opt-in
                  isBuiltIn: true,
                  sortOrder: index)
        }
        return (file.version, items)
    }

    /// Adds built-ins introduced since the version the user last saw, by ID.
    private func mergeNewBuiltIns() {
        let storedVersion = defaults.integer(forKey: DefaultsKeys.builtInSeedVersion)
        let (seedVersion, seed) = Self.loadSeed()
        guard seedVersion > storedVersion else { return }

        let existingIDs = Set(adhkar.map(\.id))
        let newOnes = seed.filter { !existingIDs.contains($0.id) }
        if !newOnes.isEmpty {
            var nextOrder = (adhkar.map(\.sortOrder).max() ?? 0) + 1
            for var item in newOnes {
                item.sortOrder = nextOrder
                nextOrder += 1
                adhkar.append(item)
            }
        }
        defaults.set(seedVersion, forKey: DefaultsKeys.builtInSeedVersion)
        saveNow()
    }

    // MARK: - CRUD

    func add(_ dhikr: Dhikr) {
        adhkar.append(dhikr)
        sortInPlace()
        scheduleSave()
    }

    /// Updates a custom item fully; for a built-in only the enabled flag is honored.
    func update(_ dhikr: Dhikr) {
        guard let i = adhkar.firstIndex(where: { $0.id == dhikr.id }) else { return }
        if adhkar[i].isBuiltIn {
            adhkar[i].isEnabled = dhikr.isEnabled
        } else {
            adhkar[i] = dhikr
        }
        sortInPlace()
        scheduleSave()
    }

    func setEnabled(_ id: String, _ enabled: Bool) {
        guard let i = adhkar.firstIndex(where: { $0.id == id }) else { return }
        adhkar[i].isEnabled = enabled
        scheduleSave()
    }

    /// Removes a custom item; disables (does not remove) a built-in.
    func delete(_ dhikr: Dhikr) {
        guard let i = adhkar.firstIndex(where: { $0.id == dhikr.id }) else { return }
        if adhkar[i].isBuiltIn {
            adhkar[i].isEnabled = false
        } else {
            adhkar.remove(at: i)
        }
        scheduleSave()
    }

    /// Returns a new, unsaved custom copy of an item (for "duplicate to edit").
    func duplicateForEditing(_ dhikr: Dhikr) -> Dhikr {
        Dhikr(arabicText: dhikr.arabicText,
              transliteration: dhikr.transliteration,
              translation: dhikr.translation,
              source: dhikr.source,
              repeatCount: dhikr.repeatCount,
              category: .custom,
              isEnabled: true,
              isBuiltIn: false,
              sortOrder: (adhkar.map(\.sortOrder).max() ?? 0) + 1)
    }

    // MARK: - Reset

    /// Restores built-ins to their canonical state, keeping user-created items.
    func resetBuiltIns() {
        let (version, seed) = Self.loadSeed()
        let userItems = adhkar.filter { !$0.isBuiltIn }
        adhkar = seed + userItems
        defaults.set(version, forKey: DefaultsKeys.builtInSeedVersion)
        sortInPlace()
        saveNow()
    }

    /// Restores built-ins and removes all user-created items.
    func resetEverything() {
        let (version, seed) = Self.loadSeed()
        adhkar = seed
        defaults.set(version, forKey: DefaultsKeys.builtInSeedVersion)
        sortInPlace()
        saveNow()
    }

    // MARK: - Saving

    private func sortInPlace() {
        adhkar.sort { $0.sortOrder < $1.sortOrder }
    }

    /// Debounced save: coalesces rapid edits, then encodes/writes off the main actor.
    private func scheduleSave() {
        saveTask?.cancel()
        let snapshot = adhkar
        let url = fileURL
        saveTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await Self.persist(snapshot, to: url)
        }
    }

    private func saveNow() {
        let snapshot = adhkar
        let url = fileURL
        Task { await Self.persist(snapshot, to: url) }
    }

    /// Encodes and writes atomically. `nonisolated` so the work runs off the
    /// main actor; inputs are `Sendable` value types.
    private nonisolated static func persist(_ items: [Dhikr], to url: URL) async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
