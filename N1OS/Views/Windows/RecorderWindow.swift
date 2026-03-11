import SwiftUI
import Combine

struct RecorderWindow: View {
    @State private var isRecording = false
    @State private var elapsed: TimeInterval = 0
    @State private var recordings: [(String, String)] = [
        ("Recording_001.wav", "2:34"),
        ("Recording_002.wav", "1:12"),
        ("Recording_003.wav", "0:45"),
    ]
    @State private var timer: AnyCancellable?

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // Status indicator
            ZStack {
                Circle()
                    .fill(isRecording ? Theme.danger.opacity(0.2) : Theme.bgTertiary)
                    .frame(width: 60, height: 60)
                if isRecording {
                    Circle()
                        .fill(Theme.danger.opacity(0.1))
                        .frame(width: 80, height: 80)
                }
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(isRecording ? Theme.danger : Theme.textSecondary)
            }

            // Timer
            Text(formattedTime)
                .font(.system(size: Theme.fontXL, weight: .light, design: .monospaced))
                .foregroundStyle(isRecording ? Theme.danger : Theme.textPrimary)

            Text(isRecording ? "Recording..." : "Ready")
                .font(.system(size: Theme.fontSmall, design: .monospaced))
                .foregroundStyle(isRecording ? Theme.danger : Theme.textMuted)

            // Controls
            HStack(spacing: 20) {
                // Record/Stop
                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Theme.bgTertiary : Theme.danger)
                            .frame(width: 40, height: 40)
                        if isRecording {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Theme.danger)
                                .frame(width: 14, height: 14)
                        } else {
                            Circle()
                                .fill(.white)
                                .frame(width: 14, height: 14)
                        }
                    }
                }

                // Save
                if isRecording {
                    Button {
                        saveRecording()
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.accent)
                            Text("Save")
                                .font(.system(size: Theme.fontMicro, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }

            Spacer()

            // Previous recordings
            Divider().background(Theme.border)

            VStack(alignment: .leading, spacing: 3) {
                Text("Recordings")
                    .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)

                ForEach(recordings, id: \.0) { name, duration in
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 8))
                            .foregroundStyle(Theme.accent)
                        Text(name)
                            .font(.system(size: Theme.fontTiny, design: .monospaced))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(duration)
                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                            .foregroundStyle(Theme.textMuted)
                        Image(systemName: "play.fill")
                            .font(.system(size: 7))
                            .foregroundStyle(Theme.accent)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
    }

    var formattedTime: String {
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        let ms = Int((elapsed.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", m, s, ms)
    }

    func startRecording() {
        isRecording = true
        elapsed = 0
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsed += 0.1
            }
    }

    func stopRecording() {
        isRecording = false
        timer?.cancel()
        timer = nil
    }

    func saveRecording() {
        stopRecording()
        let count = recordings.count + 1
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        recordings.insert(
            (String(format: "Recording_%03d.wav", count), String(format: "%d:%02d", m, s)),
            at: 0
        )
        elapsed = 0
    }
}
