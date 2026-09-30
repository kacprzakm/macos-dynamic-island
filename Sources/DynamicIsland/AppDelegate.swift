import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation {
    private var notchWindow: NotchWindow?
    private let shelf = FileShelfStore()
    private let spotify = SpotifyController()
    private let loginItem = LoginItem()

    func applicationDidFinishLaunching(_ notification: Notification) {
        loginItem.enableOnFirstLaunch()
        NSApp.mainMenu = makeMainMenu()

        let window = NotchWindow(shelf: shelf, spotify: spotify)
        window.orderFrontRegardless()
        notchWindow = window

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc private func screensChanged() {
        notchWindow?.reanchor()
    }

    private func makeMainMenu() -> NSMenu {
        let appName = ProcessInfo.processInfo.processName
        let appMenu = NSMenu(title: appName)

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        appMenu.addItem(launchItem)
        appMenu.addItem(.separator())
        appMenu.addItem(NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        let mainMenu = NSMenu()
        mainMenu.addItem(appMenuItem)
        return mainMenu
    }

    @objc private func toggleLaunchAtLogin() {
        loginItem.setEnabled(!loginItem.isEnabled)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(toggleLaunchAtLogin) {
            menuItem.state = loginItem.isEnabled ? .on : .off
            return loginItem.isAvailable
        }
        return true
    }
}
