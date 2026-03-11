import SwiftUI

struct MusicWindow: View {
    @Bindable var vm: MusicVM

    var body: some View {
        VStack(spacing: 0) {
            // Now playing section
            VStack(spacing: 6) {
                // Album art
                RoundedRectangle(cornerRadius: Theme.radiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [Theme.purple.opacity(0.6), Theme.accent.opacity(0.4), Theme.bgTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.6))
                    )

                // Title / Artist
                Text(vm.currentTrack.title)
                    .font(.system(size: Theme.fontBody, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                Text(vm.currentTrack.artist)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                Text(vm.currentTrack.album)
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textMuted)

                // Progress bar
                VStack(spacing: 2) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.bgTertiary)
                                .frame(height: 3)
                            Capsule()
                                .fill(Theme.accent)
                                .frame(width: geo.size.width * vm.progress, height: 3)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    vm.seek(to: drag.location.x / geo.size.width)
                                }
                        )
                    }
                    .frame(height: 3)

                    HStack {
                        Text(MusicTrack.formattedTime(vm.currentTime))
                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                            .foregroundStyle(Theme.textMuted)
                        Spacer()
                        Text(vm.currentTrack.durationString)
                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                .padding(.horizontal, 16)

                // Controls
                HStack(spacing: 16) {
                    Button { vm.previousTrack() } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Button { vm.togglePlay() } label: {
                        Image(systemName: vm.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.accent)
                    }
                    Button { vm.nextTrack() } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                // Volume
                HStack(spacing: 4) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(Theme.textMuted)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.bgTertiary).frame(height: 3)
                            Capsule().fill(Theme.purple).frame(width: geo.size.width * vm.volume, height: 3)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    vm.volume = min(max(drag.location.x / geo.size.width, 0), 1)
                                }
                        )
                    }
                    .frame(height: 3)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 8)

            // Playlist
            Divider().background(Theme.border).padding(.vertical, 4)

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(vm.tracks.enumerated()), id: \.element.id) { index, track in
                        Button {
                            vm.currentIndex = index
                            vm.currentTime = 0
                            if !vm.isPlaying { vm.togglePlay() }
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(index + 1)")
                                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                                    .foregroundStyle(Theme.textMuted)
                                    .frame(width: 12)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(track.title)
                                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                                        .foregroundStyle(index == vm.currentIndex ? Theme.accent : Theme.textPrimary)
                                        .lineLimit(1)
                                    Text(track.artist)
                                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                                        .foregroundStyle(Theme.textMuted)
                                }
                                Spacer()
                                Text(track.durationString)
                                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                                    .foregroundStyle(Theme.textMuted)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(index == vm.currentIndex ? Theme.accent.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
