import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchWindow: NotchWindow?
    private let shelf = FileShelfStore()
    private let spotify = SpotifyController()

    func applicationDidFinishLaunching(_ notification: Notification) {
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

    @objc private func screensChanged() {
        notchWindow?.reanchor()
    }
}
