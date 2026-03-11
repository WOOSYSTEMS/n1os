import SwiftUI

struct SystemMonitorWindow: View {
    @State private var selectedTab = "Overview"
    private let tabs = ["Overview", "Processes", "Resources"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab)
                            .font(.system(size: Theme.fontTiny, weight: selectedTab == tab ? .bold : .regular, design: .monospaced))
                            .foregroundStyle(selectedTab == tab ? Theme.accent : Theme.textMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedTab == tab ? Theme.accent.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            .background(Theme.bgSecondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    switch selectedTab {
                    case "Overview":
                        overviewTab
                    case "Processes":
                        processesTab
                    case "Resources":
                        resourcesTab
                    default:
                        EmptyView()
                    }
                }
                .padding(6)
            }
        }
    }

    var overviewTab: some View {
        VStack(alignment: .leading, spacing: 6) {
            statCard("CPU Usage", value: "34%", progress: 0.34, color: Theme.accent)
            statCard("Memory", value: "1.8 / 3.0 GB", progress: 0.62, color: Theme.purple)
            statCard("Storage", value: "18 / 32 GB", progress: 0.56, color: Theme.warning)
            statCard("Battery", value: "84%", progress: 0.84, color: Theme.success)
            statCard("Temperature", value: "42°C", progress: 0.42, color: Theme.danger)

            HStack(spacing: 8) {
                miniStat("Uptime", "3d 7h")
                miniStat("Processes", "142")
                miniStat("Threads", "487")
            }
        }
    }

    var processesTab: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("PID")
                    .frame(width: 28, alignment: .leading)
                Text("Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("CPU")
                    .frame(width: 32, alignment: .trailing)
                Text("MEM")
                    .frame(width: 32, alignment: .trailing)
            }
            .font(.system(size: Theme.fontMicro, weight: .bold, design: .monospaced))
            .foregroundStyle(Theme.accent)
            .padding(.vertical, 2)

            ForEach(processes, id: \.0) { proc in
                HStack {
                    Text(proc.0)
                        .frame(width: 28, alignment: .leading)
                    Text(proc.1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(proc.2)
                        .frame(width: 32, alignment: .trailing)
                    Text(proc.3)
                        .frame(width: 32, alignment: .trailing)
                }
                .font(.system(size: Theme.fontMicro, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
                .padding(.vertical, 1)
            }
        }
    }

    var resourcesTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CPU History")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            lineChart(data: [0.2, 0.35, 0.28, 0.42, 0.38, 0.34, 0.45, 0.32, 0.34], color: Theme.accent)

            Text("Memory History")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            lineChart(data: [0.55, 0.57, 0.58, 0.60, 0.59, 0.61, 0.62, 0.62, 0.62], color: Theme.purple)

            Text("Network I/O")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 12) {
                miniStat("↓ Down", "2.4 MB/s")
                miniStat("↑ Up", "0.8 MB/s")
            }

            Text("Disk I/O")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 12) {
                miniStat("Read", "12 MB/s")
                miniStat("Write", "4 MB/s")
            }
        }
    }

    func statCard(_ label: String, value: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(value)
                    .font(.system(size: Theme.fontTiny, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15)).frame(height: 4)
                    Capsule().fill(color).frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(4)
        .background(Theme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
    }

    func miniStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: Theme.fontMicro, design: .monospaced))
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(Theme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
    }

    func lineChart(data: [Double], color: Color) -> some View {
        GeometryReader { geo in
            Path { path in
                guard data.count > 1 else { return }
                let stepX = geo.size.width / CGFloat(data.count - 1)
                let h = geo.size.height
                path.move(to: CGPoint(x: 0, y: h * (1 - data[0])))
                for i in 1..<data.count {
                    path.addLine(to: CGPoint(x: stepX * CGFloat(i), y: h * (1 - data[i])))
                }
            }
            .stroke(color, lineWidth: 1.5)

            Path { path in
                guard data.count > 1 else { return }
                let stepX = geo.size.width / CGFloat(data.count - 1)
                let h = geo.size.height
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: h * (1 - data[0])))
                for i in 1..<data.count {
                    path.addLine(to: CGPoint(x: stepX * CGFloat(i), y: h * (1 - data[i])))
                }
                path.addLine(to: CGPoint(x: geo.size.width, y: h))
                path.closeSubpath()
            }
            .fill(color.opacity(0.1))
        }
        .frame(height: 40)
        .background(Theme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
    }

    var processes: [(String, String, String, String)] {
        [
            ("142", "ollama", "12.3%", "8.2%"),
            ("287", "n1-desktop", "5.7%", "4.1%"),
            ("312", "terminal", "2.1%", "1.8%"),
            ("445", "browser", "0.8%", "2.4%"),
            ("501", "music", "0.5%", "1.2%"),
            ("23", "systemd", "0.3%", "0.8%"),
            ("89", "dbus", "0.1%", "0.4%"),
            ("134", "NetworkMgr", "0.2%", "0.6%"),
            ("167", "bluetooth", "0.1%", "0.3%"),
            ("203", "modem-mgr", "0.4%", "0.5%"),
        ]
    }
}
