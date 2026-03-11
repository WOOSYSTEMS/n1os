import Foundation

struct MusicTrack: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval

    var durationString: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }

    static func formattedTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }

    static let sampleTracks: [MusicTrack] = [
        MusicTrack(title: "Digital Dreams", artist: "Neural Wave", album: "Synthetic Horizons", duration: 234),
        MusicTrack(title: "Quantum Pulse", artist: "Cyber Echo", album: "Binary Sunset", duration: 198),
        MusicTrack(title: "Neon Cascade", artist: "Data Stream", album: "Electric Dawn", duration: 267),
        MusicTrack(title: "Silicon Heart", artist: "Neural Wave", album: "Synthetic Horizons", duration: 312),
        MusicTrack(title: "Byte Runner", artist: "Pixel Ghost", album: "RAM City", duration: 185),
    ]
}
