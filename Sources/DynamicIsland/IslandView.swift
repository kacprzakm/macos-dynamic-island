import SwiftUI
import UniformTypeIdentifiers

struct IslandView: View {
    @ObservedObject var shelf: FileShelfStore
    @ObservedObject var spotify: SpotifyController
    @ObservedObject var model: IslandModel

    private var cornerRadius: CGFloat { model.isExpanded ? 28 : 12 }

    var body: some View {
        ZStack(alignment: .top) {
            islandShape
            if model.isExpanded {
                expandedContent
                    .padding(.horizontal, 14)
                    .padding(.top, model.notchHeight + 6)
                    .padding(.bottom, 14)
                    .transition(.opacity)
            } else {
                collapsedContent
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onDrop(of: [.fileURL], isTargeted: dropBinding) { providers in
            handleDrop(providers)
        }
    }

    private var islandShape: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: cornerRadius,
            bottomTrailingRadius: cornerRadius,
            topTrailingRadius: 0,
            style: .continuous
        )
        return shape
            .fill(.black)
            .overlay(
                shape.strokeBorder(model.isDropTargeted ? Color.accentColor : .clear, lineWidth: 2)
            )
    }

    private var collapsedContent: some View {
        HStack(spacing: 0) {
            if !shelf.items.isEmpty {
                Spacer()
                Label("\(shelf.items.count)", systemImage: "tray.full")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity)
    }

    private var expandedContent: some View {
        VStack(spacing: 10) {
            spotifySection
            Divider().overlay(Color.white.opacity(0.2))
            shelfSection
        }
    }

    private var spotifySection: some View {
        HStack(spacing: 10) {
            artwork(size: 44, radius: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(spotify.isRunning ? (spotify.track.isEmpty ? "Nothing playing" : spotify.track) : "Spotify not running")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(spotify.artist)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer(minLength: 4)

            HStack(spacing: 12) {
                transportButton("backward.fill", action: spotify.previous)
                transportButton(spotify.isPlaying ? "pause.fill" : "play.fill", action: spotify.playPause)
                transportButton("forward.fill", action: spotify.next)
            }
        }
    }

    private func artwork(size: CGFloat, radius: CGFloat) -> some View {
        Group {
            if let art = spotify.artwork {
                Image(nsImage: art).resizable().scaledToFill()
            } else {
                Image(systemName: "music.note")
                    .resizable().scaledToFit().padding(size * 0.22)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    private func transportButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!spotify.isRunning)
        .opacity(spotify.isRunning ? 1 : 0.4)
    }

    private var shelfSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Shelf")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                if !shelf.items.isEmpty {
                    Button("Clear") { shelf.clear() }
                        .buttonStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            if shelf.items.isEmpty {
                Text("Drop files here")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(shelf.items) { item in
                            shelfRow(item)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func shelfRow(_ item: ShelfItem) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))
            Text(item.name)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            Button {
                shelf.remove(item)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onDrag { NSItemProvider(object: item.url as NSURL) }
    }

    private var dropBinding: Binding<Bool> {
        Binding(get: { model.isDropTargeted }, set: { model.isDropTargeted = $0 })
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url else { return }
                DispatchQueue.main.async { shelf.add(url) }
            }
        }
        return true
    }
}
