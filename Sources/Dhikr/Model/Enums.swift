import Foundation

/// Category of a remembrance. Used for grouping in the library and for
/// time-aware selection (morning/evening).
enum DhikrCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case general
    case morning
    case evening
    case afterPrayer
    case sleep
    case custom

    var id: String { rawValue }

    func localizedName(_ lang: AppLanguage) -> String {
        let ar = lang == .arabic
        switch self {
        case .general:     return ar ? "أذكار عامة" : "General"
        case .morning:     return ar ? "أذكار الصباح" : "Morning"
        case .evening:     return ar ? "أذكار المساء" : "Evening"
        case .afterPrayer: return ar ? "أذكار بعد الصلاة" : "After prayer"
        case .sleep:       return ar ? "أذكار النوم" : "Before sleep"
        case .custom:      return ar ? "أذكاري" : "My adhkar"
        }
    }
}

/// Screen corner where the popup appears. Names are absolute (not RTL-relative)
/// so the positioning math is unambiguous.
enum ScreenCorner: String, CaseIterable, Identifiable, Sendable {
    case topRight
    case topLeft
    case bottomRight
    case bottomLeft

    var id: String { rawValue }

    func localizedName(_ lang: AppLanguage) -> String {
        let ar = lang == .arabic
        switch self {
        case .topRight:    return ar ? "أعلى اليمين" : "Top right"
        case .topLeft:     return ar ? "أعلى اليسار" : "Top left"
        case .bottomRight: return ar ? "أسفل اليمين" : "Bottom right"
        case .bottomLeft:  return ar ? "أسفل اليسار" : "Bottom left"
        }
    }
}

/// How the next remembrance is chosen at each interval.
enum SelectionMode: String, CaseIterable, Identifiable, Sendable {
    case shuffledBag
    case sequential
    case random

    var id: String { rawValue }

    func localizedName(_ lang: AppLanguage) -> String {
        let ar = lang == .arabic
        switch self {
        case .shuffledBag: return ar ? "عشوائي متوازن" : "Shuffled (balanced)"
        case .sequential:  return ar ? "بالترتيب" : "In order"
        case .random:      return ar ? "عشوائي" : "Random"
        }
    }
}

/// Which display the popup targets on a multi-monitor setup.
enum ScreenMode: String, CaseIterable, Identifiable, Sendable {
    case withCursor
    case main

    var id: String { rawValue }

    func localizedName(_ lang: AppLanguage) -> String {
        let ar = lang == .arabic
        switch self {
        case .withCursor: return ar ? "الشاشة التي بها المؤشّر" : "Screen with the cursor"
        case .main:       return ar ? "الشاشة الرئيسية" : "Main screen"
        }
    }
}

/// Period of the day, derived from the current hour, used for time-aware selection.
enum DayPeriod {
    case morning
    case evening
    case other

    /// Morning window ≈ Fajr to late morning; evening window ≈ Asr to after Maghrib.
    static func current(hour: Int) -> DayPeriod {
        switch hour {
        case 4..<11:  return .morning
        case 15..<20: return .evening
        default:      return .other
        }
    }
}
