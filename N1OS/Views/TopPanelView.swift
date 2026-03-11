import SwiftUI

struct TopPanelView: View {
    let desktop: DesktopVM
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            // Left: time
            Text(timeString)
                .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            // Center: tray icons
            HStack(spacing: 6) {
                Image(systemName: "wifi")
                    .font(.system(size: 7))
                    .foregroundStyle(Theme.success)

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 7))
                    .foregroundStyle(Theme.accent)

                Image(systemName: "bluetooth")
                    .font(.system(size: 7))
                    .foregroundStyle(Theme.accent)
            }

            Spacer()

            // Right: battery + controls
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    Image(systemName: "battery.75")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.success)
                    Text("84%")
                        .font(.system(size: Theme.fontTiny, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        desktop.showNotifications.toggle()
                        desktop.showQuickSettings = false
                    }
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(Theme.textSecondary)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        desktop.showQuickSettings.toggle()
                        desktop.showNotifications = false
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: Theme.topPanelHeight)
        .background(Theme.bgPrimary.opacity(0.95))
        .onReceive(timer) { t in
            currentTime = t
        }
    }

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
    }
}
