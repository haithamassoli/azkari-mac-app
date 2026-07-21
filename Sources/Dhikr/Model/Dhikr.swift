import Foundation

/// A single remembrance (ذِكر). Value type — `Sendable`, so an immutable
/// snapshot can be handed to a background task for JSON encoding.
struct Dhikr: Identifiable, Codable, Hashable, Sendable {
    /// Stable identifier. Built-in items use fixed string IDs (e.g. "gen-subhanallah");
    /// user-created items use a UUID string.
    let id: String
    var arabicText: String
    var transliteration: String?
    var translation: String?
    var source: String?
    /// Traditional repetition count (e.g. 33). 1 means "no specific count".
    var repeatCount: Int
    var category: DhikrCategory
    var isEnabled: Bool
    /// Built-in items are seeded from the bundle and are read-only (text cannot be
    /// edited; "deleting" one only disables it).
    let isBuiltIn: Bool
    var sortOrder: Int

    init(id: String = UUID().uuidString,
         arabicText: String,
         transliteration: String? = nil,
         translation: String? = nil,
         source: String? = nil,
         repeatCount: Int = 1,
         category: DhikrCategory = .custom,
         isEnabled: Bool = true,
         isBuiltIn: Bool = false,
         sortOrder: Int = 0) {
        self.id = id
        self.arabicText = arabicText
        self.transliteration = transliteration
        self.translation = translation
        self.source = source
        self.repeatCount = repeatCount
        self.category = category
        self.isEnabled = isEnabled
        self.isBuiltIn = isBuiltIn
        self.sortOrder = sortOrder
    }

    // Tolerant decoder so adding fields later never breaks an existing user file.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        arabicText = try c.decode(String.self, forKey: .arabicText)
        transliteration = try c.decodeIfPresent(String.self, forKey: .transliteration)
        translation = try c.decodeIfPresent(String.self, forKey: .translation)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        repeatCount = try c.decodeIfPresent(Int.self, forKey: .repeatCount) ?? 1
        category = try c.decodeIfPresent(DhikrCategory.self, forKey: .category) ?? .general
        isEnabled = try c.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        isBuiltIn = try c.decodeIfPresent(Bool.self, forKey: .isBuiltIn) ?? false
        sortOrder = try c.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
    }

    /// Main display text: the transliteration when `english` is on and present,
    /// else the Arabic. Shared by the popup card and the library list.
    func displayText(english: Bool) -> String {
        guard english, let t = transliteration, !t.isEmpty else { return arabicText }
        return t
    }
}

/// Shape of the bundled seed file `Resources/adhkar.json`.
struct SeedFile: Decodable {
    let version: Int
    let adhkar: [SeedItem]

    struct SeedItem: Decodable {
        let id: String
        let arabicText: String
        let transliteration: String?
        let translation: String?
        let source: String?
        let repeatCount: Int?
        let category: DhikrCategory
    }
}
