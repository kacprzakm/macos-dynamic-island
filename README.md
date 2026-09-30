# macos-dynamic-island

Dynamic Island from iPhone but on the MacBook notch.

Hover over the notch and it opens. Shows what's playing on Spotify and you can
pause / skip. You can also drop files on it and they stay there until you remove them.
When music is playing it shows the cover and a little waveform next to the notch.

Made it because I wanted this on my Mac and didn't want to pay for an app.

## Install

```
./scripts/bundle.sh --open
```

Builds the app, puts it in /Applications and opens it. It starts by itself after login
(you can turn that off in the app menu > Launch at Login).

Needs macOS 13+. No Xcode project, it's just a Swift package.

For quick testing without installing:

```
swift run DynamicIsland
```

## Notes

- Spotify desktop app has to be open. First time you click play macOS will ask for
  permission, just allow it (or System Settings > Privacy & Security > Automation).
- Files you drop are copied to `~/Library/Application Support/DynamicIsland/shelf/`
- Works best on a Mac with a notch, on other screens it's just a black pill at the top.
