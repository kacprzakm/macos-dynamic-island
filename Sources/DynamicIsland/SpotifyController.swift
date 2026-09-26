import AppKit
import Combine

final class SpotifyController: ObservableObject {
    @Published var track = ""
    @Published var artist = ""
    @Published var isPlaying = false
    @Published var isRunning = false
    @Published var artwork: NSImage?

    private var timer: Timer?
    private var lastArtworkURL = ""

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        refresh()
    }

    deinit { timer?.invalidate() }

    func playPause() { run("playpause"); refresh() }
    func next()      { run("next track"); refresh() }
    func previous()  { run("previous track"); refresh() }

    func refresh() {
        guard spotifyRunning() else {
            isRunning = false
            isPlaying = false
            return
        }
        isRunning = true

        let script = """
        tell application "Spotify"
            set playerState to player state as string
            set trackName to name of current track
            set trackArtist to artist of current track
            set artworkLink to artwork url of current track
            return playerState & "\u{1F}" & trackName & "\u{1F}" & trackArtist & "\u{1F}" & artworkLink
        end tell
        """
        guard let out = execute(script) else { return }
        let parts = out.components(separatedBy: "\u{1F}")
        guard parts.count >= 4 else { return }

        isPlaying = parts[0] == "playing"
        track = parts[1]
        artist = parts[2]
        loadArtwork(from: parts[3])
    }

    private func run(_ command: String) {
        _ = execute("tell application \"Spotify\" to \(command)")
    }

    private func spotifyRunning() -> Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == "com.spotify.client"
        }
    }

    private func loadArtwork(from urlString: String) {
        guard urlString != lastArtworkURL, let url = URL(string: urlString) else { return }
        lastArtworkURL = urlString
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = NSImage(data: data) else { return }
            DispatchQueue.main.async { self?.artwork = image }
        }.resume()
    }

    @discardableResult
    private func execute(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&error)
        if let error { NSLog("Spotify AppleScript error: \(error)"); return nil }
        return result.stringValue
    }
}
