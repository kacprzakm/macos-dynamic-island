import Foundation
import ServiceManagement

struct LoginItem {
    private let setupKey = "didSetUpLoginItem"

    var isAvailable: Bool { Bundle.main.bundleIdentifier != nil }

    var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    func setEnabled(_ enabled: Bool) {
        guard isAvailable else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Login item update failed: \(error)")
        }
    }

    func enableOnFirstLaunch() {
        guard isAvailable, !UserDefaults.standard.bool(forKey: setupKey) else { return }
        UserDefaults.standard.set(true, forKey: setupKey)
        setEnabled(true)
    }
}
