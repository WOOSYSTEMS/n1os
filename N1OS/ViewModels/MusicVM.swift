import SwiftUI
import Combine

@Observable
class MusicVM {
    var tracks = MusicTrack.sampleTracks
    var currentIndex: Int = 0
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var volume: Double = 0.7

    private var timer: AnyCancellable?

    var currentTrack: MusicTrack {
        tracks[currentIndex]
    }

    var progress: Double {
        guard currentTrack.duration > 0 else { return 0 }
        return currentTime / currentTrack.duration
    }

    func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
    }

    func nextTrack() {
        currentIndex = (currentIndex + 1) % tracks.count
        currentTime = 0
        if isPlaying { startTimer() }
    }

    func previousTrack() {
        if currentTime > 3 {
            currentTime = 0
        } else {
            currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
            currentTime = 0
        }
        if isPlaying { startTimer() }
    }

    func seek(to fraction: Double) {
        currentTime = currentTrack.duration * fraction
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isPlaying else { return }
                self.currentTime += 0.5
                if self.currentTime >= self.currentTrack.duration {
                    self.nextTrack()
                }
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
