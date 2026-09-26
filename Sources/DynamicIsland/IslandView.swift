import SwiftUI

struct IslandView: View {
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var islandShape: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: cornerRadius,
            bottomTrailingRadius: cornerRadius,
            topTrailingRadius: 0,
            style: .continuous
        )
        .fill(.black)
    }

    private var expandedContent: some View {
        VStack(spacing: 10) {
            spotifySection
            Spacer(minLength: 0)
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
}
