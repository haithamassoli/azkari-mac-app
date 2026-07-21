import SwiftUI

/// Centralized UserDefaults keys.
enum DefaultsKeys {
    static let builtInSeedVersion = "builtInSeedVersion"
    static let intervalMinutes    = "intervalMinutes"
    static let displayDuration    = "displayDuration"
    static let corner             = "corner"
    static let selectionMode      = "selectionMode"
    static let screenMode         = "screenMode"
    static let fontSize           = "fontSize"
    static let showTransliteration = "showTransliteration"
    static let showTranslation    = "showTranslation"
    static let soundEnabled       = "soundEnabled"
    static let timeAwareEnabled   = "timeAwareEnabled"
    static let counterEnabled     = "counterEnabled"
    static let language           = "language"
    static let adhkarInEnglish    = "adhkarInEnglish"
    static let hasOnboarded       = "hasOnboarded"
}

/// Observable, UserDefaults-backed settings. A single instance lives on `AppModel`
/// and is shared by the SwiftUI settings views (which bind to it) and the
/// scheduler/selector/panel logic (which read it). Each property persists on `didSet`.
@MainActor
@Observable
final class Preferences {
    var intervalMinutes: Int { didSet { d.set(intervalMinutes, forKey: DefaultsKeys.intervalMinutes) } }
    var displayDuration: Double { didSet { d.set(displayDuration, forKey: DefaultsKeys.displayDuration) } }
    var corner: ScreenCorner { didSet { d.set(corner.rawValue, forKey: DefaultsKeys.corner) } }
    var selectionMode: SelectionMode { didSet { d.set(selectionMode.rawValue, forKey: DefaultsKeys.selectionMode) } }
    var screenMode: ScreenMode { didSet { d.set(screenMode.rawValue, forKey: DefaultsKeys.screenMode) } }
    var fontSize: Double { didSet { d.set(fontSize, forKey: DefaultsKeys.fontSize) } }
    var showTransliteration: Bool { didSet { d.set(showTransliteration, forKey: DefaultsKeys.showTransliteration) } }
    var showTranslation: Bool { didSet { d.set(showTranslation, forKey: DefaultsKeys.showTranslation) } }
    var soundEnabled: Bool { didSet { d.set(soundEnabled, forKey: DefaultsKeys.soundEnabled) } }
    var timeAwareEnabled: Bool { didSet { d.set(timeAwareEnabled, forKey: DefaultsKeys.timeAwareEnabled) } }
    var counterEnabled: Bool { didSet { d.set(counterEnabled, forKey: DefaultsKeys.counterEnabled) } }
    /// UI language. Defaults to the system language (falling back to Arabic) until
    /// the user picks one, then persists their choice.
    var language: AppLanguage { didSet { d.set(language.rawValue, forKey: DefaultsKeys.language) } }
    /// When on, the popup shows each dhikr's transliteration (e.g. "Al-ḥamdu lillāh")
    /// as the main text instead of the Arabic. Independent of the UI `language`.
    var adhkarInEnglish: Bool { didSet { d.set(adhkarInEnglish, forKey: DefaultsKeys.adhkarInEnglish) } }

    private let d = UserDefaults.standard

    init() {
        d.register(defaults: [
            DefaultsKeys.intervalMinutes: 5,
            DefaultsKeys.displayDuration: 15.0,
            DefaultsKeys.corner: ScreenCorner.topRight.rawValue,
            DefaultsKeys.selectionMode: SelectionMode.shuffledBag.rawValue,
            DefaultsKeys.screenMode: ScreenMode.withCursor.rawValue,
            DefaultsKeys.fontSize: 28.0,
            DefaultsKeys.showTransliteration: false,
            DefaultsKeys.showTranslation: false,
            DefaultsKeys.soundEnabled: false,
            DefaultsKeys.timeAwareEnabled: false,
            DefaultsKeys.counterEnabled: false,
            DefaultsKeys.adhkarInEnglish: false,
        ])
        // Initial assignment in init does not trigger didSet, so this reads
        // without writing back.
        intervalMinutes    = d.integer(forKey: DefaultsKeys.intervalMinutes)
        displayDuration    = d.double(forKey: DefaultsKeys.displayDuration)
        corner             = ScreenCorner(rawValue: d.string(forKey: DefaultsKeys.corner) ?? "") ?? .topRight
        selectionMode      = SelectionMode(rawValue: d.string(forKey: DefaultsKeys.selectionMode) ?? "") ?? .shuffledBag
        screenMode         = ScreenMode(rawValue: d.string(forKey: DefaultsKeys.screenMode) ?? "") ?? .withCursor
        fontSize           = d.double(forKey: DefaultsKeys.fontSize)
        showTransliteration = d.bool(forKey: DefaultsKeys.showTransliteration)
        showTranslation    = d.bool(forKey: DefaultsKeys.showTranslation)
        soundEnabled       = d.bool(forKey: DefaultsKeys.soundEnabled)
        timeAwareEnabled   = d.bool(forKey: DefaultsKeys.timeAwareEnabled)
        counterEnabled     = d.bool(forKey: DefaultsKeys.counterEnabled)
        adhkarInEnglish    = d.bool(forKey: DefaultsKeys.adhkarInEnglish)
        // No static default (the fallback is dynamic): use the stored choice, else the system language.
        language           = d.string(forKey: DefaultsKeys.language).flatMap(AppLanguage.init(rawValue:)) ?? .systemDefault
    }
}
