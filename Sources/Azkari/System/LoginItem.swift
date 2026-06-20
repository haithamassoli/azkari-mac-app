import ServiceManagement

/// Thin wrapper around `SMAppService.mainApp` for launch-at-login.
///
/// Requires a real app bundle with a stable bundle identifier (we have one).
/// On a machine with no Developer ID the registration still works for local
/// use but can behave inconsistently across reboots until the app is signed.
@MainActor
enum LoginItem {
    static var status: SMAppService.Status { SMAppService.mainApp.status }

    static var isEnabled: Bool { status == .enabled }

    /// `true` when the user has switched the item off in System Settings.
    static var requiresApproval: Bool { status == .requiresApproval }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        }
    }

    /// Opens System Settings ▸ General ▸ Login Items (used when approval is needed).
    static func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
