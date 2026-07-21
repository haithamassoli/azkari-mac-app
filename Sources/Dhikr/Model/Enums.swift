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

    /// Arabic display name for the category.
    var arabicName: String {
        switch self {
        case .general:     return "أذكار عامة"
        case .morning:     return "أذكار الصباح"
        case .evening:     return "أذكار المساء"
        case .afterPrayer: return "أذكار بعد الصلاة"
        case .sleep:       return "أذكار النوم"
        case .custom:      return "أذكاري"
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

    var arabicName: String {
        switch self {
        case .topRight:    return "أعلى اليمين"
        case .topLeft:     return "أعلى اليسار"
        case .bottomRight: return "أسفل اليمين"
        case .bottomLeft:  return "أسفل اليسار"
        }
    }
}

/// How the next remembrance is chosen at each interval.
enum SelectionMode: String, CaseIterable, Identifiable, Sendable {
    case shuffledBag
    case sequential
    case random

    var id: String { rawValue }

    var arabicName: String {
        switch self {
        case .shuffledBag: return "عشوائي متوازن"
        case .sequential:  return "بالترتيب"
        case .random:      return "عشوائي"
        }
    }
}

/// Which display the popup targets on a multi-monitor setup.
enum ScreenMode: String, CaseIterable, Identifiable, Sendable {
    case withCursor
    case main

    var id: String { rawValue }

    var arabicName: String {
        switch self {
        case .withCursor: return "الشاشة التي بها المؤشّر"
        case .main:       return "الشاشة الرئيسية"
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
