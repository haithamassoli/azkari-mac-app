import SwiftUI

/// The two languages the UI ships in. Arabic is the app's origin language and
/// stays the fallback; English is the added translation.
///
// ponytail: an in-code string table (LocKey below) beats .lproj bundle-swapping
// for runtime in-app switching — flip `language` and SwiftUI re-renders, no app
// restart, no XcodeGen resource wiring. Migrate to a String Catalog only if the
// string count balloons or external translators need .xliff.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case arabic = "ar"
    case english = "en"

    var id: String { rawValue }

    /// Chrome direction. The religious Arabic text renders RTL on its own
    /// regardless; this only orients the surrounding UI.
    var layoutDirection: LayoutDirection { self == .arabic ? .rightToLeft : .leftToRight }

    var locale: Locale { Locale(identifier: rawValue) }

    /// Shown in its own script in the language picker, so each option is
    /// legible whatever the current UI language is.
    var nativeName: String { self == .arabic ? "العربية" : "English" }

    /// First-launch default: match the system language when we ship it, else Arabic.
    static var systemDefault: AppLanguage {
        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "ar"
        return AppLanguage(rawValue: String(code)) ?? .arabic
    }

    /// Localized text for a key.
    func tr(_ key: LocKey) -> String { key.text(self) }

    /// Localized format string filled with `args` (for the `%d` interpolations).
    func tr(_ key: LocKey, _ args: CVarArg...) -> String {
        String(format: key.text(self), arguments: args)
    }
}

/// Every user-facing UI string. The religious content in `adhkar.json`
/// (Arabic text, transliteration, English translation, source) is data, not
/// listed here.
enum LocKey {
    // App & menu bar
    case appName
    case menuShowNow, menuNoneEnabled, pauseReminders, resumeReminders, menuSettings, menuQuit

    // Popup card
    case close, counterDone, tapToCount

    // General settings
    case sectionReminders, intervalEvery, selectionMethod, timeAware
    case sectionDisplay, screenLabel
    case sectionStartup, launchAtLogin, loginDisabledBySystem, openSystemSettings
    case languageLabel

    // Appearance settings
    case sectionPosition, cornerLabel
    case sectionDuration, displayDurationSecs
    case sectionFontContent, fontSizeLabel, adhkarInEnglish, showTransliteration, showTranslation, showCounter
    case sectionSound, playSoundOnShow, testSound
    case previewNow

    // Library
    case addDhikr, resetEllipsis, resetTitle, resetBuiltInsOnly, resetEverything, cancel
    case resetMessage, builtInBadge, duplicateToEdit, edit, delete

    // Editor
    case sectionText, arabicTextField, sectionOptionalDetails
    case transliterationField, translationField, sourceField, repeatCountLabel, categoryField
    case add, save

    // About
    case aboutTagline, aboutVersion, aboutBody

    // Settings tabs
    case tabGeneral, tabAppearance, tabLibrary, tabAbout

    // Onboarding
    case onbWelcomeTitle, onbWelcomeSubtitle, onbIntervalQuestion, onbMinutes, onbChooseAdhkar, onbStart

    /// `%d` placeholders are filled by `AppLanguage.tr(_:_:)`.
    func text(_ lang: AppLanguage) -> String {
        let ar = lang == .arabic
        switch self {
        case .appName:          return ar ? "ذِكر" : "Dhikr"
        case .menuShowNow:      return ar ? "أظهر ذِكرًا الآن" : "Show a Dhikr Now"
        case .menuNoneEnabled:  return ar ? "لا توجد أذكار مُفعَّلة" : "No remembrances enabled"
        case .pauseReminders:   return ar ? "إيقاف التذكير مؤقتًا" : "Pause Reminders"
        case .resumeReminders:  return ar ? "استئناف التذكير" : "Resume Reminders"
        case .menuSettings:     return ar ? "الإعدادات…" : "Settings…"
        case .menuQuit:         return ar ? "إنهاء ذكر" : "Quit Dhikr"

        case .close:            return ar ? "إغلاق" : "Close"
        case .counterDone:      return ar ? "تمّ بحمد الله" : "Done — praise be to Allah"
        case .tapToCount:       return ar ? "اضغط للعدّ" : "Tap to count"

        case .sectionReminders: return ar ? "التذكير" : "Reminders"
        case .intervalEvery:    return ar ? "الفاصل الزمني: كل %d دقيقة" : "Interval: every %d min"
        case .selectionMethod:  return ar ? "طريقة الاختيار" : "Selection method"
        case .timeAware:        return ar ? "الاختيار حسب وقت اليوم (صباح/مساء)" : "Match time of day (morning/evening)"
        case .sectionDisplay:   return ar ? "العرض" : "Display"
        case .screenLabel:      return ar ? "الشاشة" : "Screen"
        case .sectionStartup:   return ar ? "بدء التشغيل" : "Startup"
        case .launchAtLogin:    return ar ? "التشغيل عند تسجيل الدخول" : "Launch at login"
        case .loginDisabledBySystem: return ar ? "التشغيل عند الدخول مُعطَّل من إعدادات النظام." : "Launch at login is disabled in System Settings."
        case .openSystemSettings:    return ar ? "فتح إعدادات النظام" : "Open System Settings"
        case .languageLabel:    return ar ? "اللغة" : "Language"

        case .sectionPosition:  return ar ? "الموضع" : "Position"
        case .cornerLabel:      return ar ? "زاوية الظهور" : "Corner"
        case .sectionDuration:  return ar ? "المدّة" : "Duration"
        case .displayDurationSecs: return ar ? "مدّة الظهور: %d ثانية" : "Display duration: %d s"
        case .sectionFontContent:  return ar ? "الخط والمحتوى" : "Font & content"
        case .fontSizeLabel:    return ar ? "حجم الخط: %d" : "Font size: %d"
        case .adhkarInEnglish:  return ar ? "عرض الأذكار بالإنجليزية (مثل Alhamdulillah)" : "Show adhkar in English (e.g. Alhamdulillah)"
        case .showTransliteration: return ar ? "إظهار النقحرة (حروف لاتينية)" : "Show transliteration (Latin letters)"
        case .showTranslation:  return ar ? "إظهار الترجمة" : "Show translation"
        case .showCounter:      return ar ? "إظهار عدّاد التسبيح (اضغط للعدّ)" : "Show tasbeeh counter (tap to count)"
        case .sectionSound:     return ar ? "الصوت" : "Sound"
        case .playSoundOnShow:  return ar ? "تشغيل صوت عند الظهور" : "Play a sound when shown"
        case .testSound:        return ar ? "تجربة الصوت" : "Test sound"
        case .previewNow:       return ar ? "معاينة التذكير الآن" : "Preview reminder now"

        case .addDhikr:         return ar ? "إضافة ذِكر" : "Add Dhikr"
        case .resetEllipsis:    return ar ? "إعادة التعيين…" : "Reset…"
        case .resetTitle:       return ar ? "إعادة تعيين الأذكار" : "Reset remembrances"
        case .resetBuiltInsOnly: return ar ? "إعادة الأذكار الأصلية فقط" : "Reset built-in remembrances only"
        case .resetEverything:  return ar ? "إعادة كل شيء (يحذف أذكاري)" : "Reset everything (deletes my remembrances)"
        case .cancel:           return ar ? "إلغاء" : "Cancel"
        case .resetMessage:     return ar ? "يمكنك إعادة الأذكار الأصلية فقط، أو إعادة كل شيء وحذف أذكارك المضافة." : "You can reset only the built-in remembrances, or reset everything and delete the ones you added."
        case .builtInBadge:     return ar ? "أصلي" : "Built-in"
        case .duplicateToEdit:  return ar ? "نسخ للتعديل" : "Duplicate to edit"
        case .edit:             return ar ? "تعديل" : "Edit"
        case .delete:           return ar ? "حذف" : "Delete"

        case .sectionText:      return ar ? "النص" : "Text"
        case .arabicTextField:  return ar ? "النص العربي" : "Arabic text"
        case .sectionOptionalDetails: return ar ? "تفاصيل (اختياري)" : "Details (optional)"
        case .transliterationField:   return ar ? "النقحرة" : "Transliteration"
        case .translationField: return ar ? "الترجمة" : "Translation"
        case .sourceField:      return ar ? "المصدر" : "Source"
        case .repeatCountLabel: return ar ? "عدد التكرار: %d" : "Repeat count: %d"
        case .categoryField:    return ar ? "التصنيف" : "Category"
        case .add:              return ar ? "إضافة" : "Add"
        case .save:             return ar ? "حفظ" : "Save"

        case .aboutTagline:     return ar ? "تطبيقٌ يعرض الأذكار بشكلٍ دوري في زاوية الشاشة." : "An app that periodically shows remembrances in a corner of your screen."
        case .aboutVersion:     return ar ? "الإصدار ١٫٠" : "Version 1.0"
        case .aboutBody:        return ar ? "الأذكار المضمّنة من المأثور المشهور، ويمكنك تعديلها وإضافة أذكارك الخاصة." : "The built-in remembrances come from well-known tradition; you can edit them and add your own."

        case .tabGeneral:       return ar ? "عام" : "General"
        case .tabAppearance:    return ar ? "المظهر" : "Appearance"
        case .tabLibrary:       return ar ? "الأذكار" : "Adhkar"
        case .tabAbout:         return ar ? "حول" : "About"

        case .onbWelcomeTitle:    return ar ? "أهلًا بك في ذِكر" : "Welcome to Dhikr"
        case .onbWelcomeSubtitle: return ar ? "لنُهيّئ تذكيراتك في خطوات قصيرة." : "Let's set up your reminders in a few quick steps."
        case .onbIntervalQuestion: return ar ? "كل كم يظهر التذكير؟" : "How often should a reminder appear?"
        case .onbMinutes:         return ar ? "%d دقيقة" : "%d min"
        case .onbChooseAdhkar:    return ar ? "اختر الأذكار التي تريد تفعيلها" : "Choose which adhkar to enable"
        case .onbStart:           return ar ? "ابدأ الآن" : "Get Started"
        }
    }
}
