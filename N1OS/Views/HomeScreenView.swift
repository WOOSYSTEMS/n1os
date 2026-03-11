import SwiftUI

struct HomeScreenView: View {
    let desktop: DesktopVM
    let musicVM: MusicVM
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 6) {
                clockWidget
                aiStatusWidget
                quickLaunchWidget
                systemStatsWidget
                musicMiniWidget
                recentFilesWidget
                tasksWidget
            }
            .padding(.horizontal, 6)
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .onReceive(timer) { t in currentTime = t }
    }

    // MARK: - Clock Widget
    var clockWidget: some View {
        VStack(spacing: 2) {
            Text(timeString)
                .font(.system(size: Theme.fontXXL, weight: .light, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
            Text(dateString)
                .font(.system(size: Theme.fontSmall, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            Text(greetingString)
                .font(.system(size: Theme.fontTiny, design: .monospaced))
                .foregroundStyle(Theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    // MARK: - AI Status Widget
    var aiStatusWidget: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.success)
                .frame(width: 6, height: 6)
                .shadow(color: Theme.success.opacity(0.5), radius: 3)
            VStack(alignment: .leading, spacing: 1) {
                Text("N1 Neural Engine")
                    .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                Text("llama-3.2 · Ready")
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button {
                desktop.openWindow(.aiChat)
            } label: {
                Text("Chat")
                    .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.bgPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    // MARK: - Quick Launch
    var quickLaunchWidget: some View {
        HStack(spacing: 8) {
            quickLaunchButton(.terminal)
            quickLaunchButton(.browser)
            quickLaunchButton(.files)
            quickLaunchButton(.camera)
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    func quickLaunchButton(_ app: AppWindowID) -> some View {
        Button {
            desktop.openWindow(app)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: app.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(app.accentColor)
                Text(app.title)
                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - System Stats
    var systemStatsWidget: some View {
        HStack(spacing: 12) {
            statsRing(label: "CPU", value: 0.34, color: Theme.accent)
            statsRing(label: "RAM", value: 0.62, color: Theme.purple)
            statsRing(label: "BAT", value: 0.84, color: Theme.success)
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    func statsRing(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(value * 100))%")
                    .font(.system(size: 6, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.system(size: Theme.fontMicro, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Music Mini Player
    var musicMiniWidget: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: [Theme.purple.opacity(0.6), Theme.accent.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(musicVM.currentTrack.title)
                    .font(.system(size: Theme.fontSmall, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(musicVM.currentTrack.artist)
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            Button {
                musicVM.previousTrack()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.textSecondary)
            }
            Button {
                musicVM.togglePlay()
            } label: {
                Image(systemName: musicVM.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.accent)
            }
            Button {
                musicVM.nextTrack()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
        .onTapGesture { desktop.openWindow(.music) }
    }

    // MARK: - Recent Files
    var recentFilesWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Files")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            ForEach(recentFiles, id: \.0) { name, icon, time in
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 14)
                    Text(name)
                        .font(.system(size: Theme.fontTiny, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(time)
                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    var recentFiles: [(String, String, String)] {
        [
            ("neural_net.py", "chevron.left.forwardslash.chevron.right", "2m"),
            ("report.pdf", "doc.richtext", "1h"),
            ("photo_001.png", "photo", "3h"),
        ]
    }

    // MARK: - Tasks Widget
    var tasksWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Tasks")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            ForEach(tasks, id: \.0) { task, done in
                HStack(spacing: 6) {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 8))
                        .foregroundStyle(done ? Theme.success : Theme.textMuted)
                    Text(task)
                        .font(.system(size: Theme.fontTiny, design: .monospaced))
                        .foregroundStyle(done ? Theme.textMuted : Theme.textPrimary)
                        .strikethrough(done)
                    Spacer()
                }
            }
        }
        .padding(8)
        .background(Theme.bgCard.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
    }

    var tasks: [(String, Bool)] {
        [
            ("Train model v2.1", true),
            ("Review PR #847", false),
            ("Deploy staging", false),
        ]
    }

    // MARK: - Helpers
    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: currentTime)
    }

    var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: currentTime)
    }

    var greetingString: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        if hour < 12 { return "Good Morning, User" }
        if hour < 17 { return "Good Afternoon, User" }
        return "Good Evening, User"
    }
}
