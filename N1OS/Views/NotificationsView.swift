import SwiftUI

struct NotificationsView: View {
    let desktop: DesktopVM
    @State private var notifications: [NotificationItem] = NotificationItem.samples

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Notifications")
                    .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Button {
                    withAnimation { notifications.removeAll() }
                } label: {
                    Text("Clear All")
                        .font(.system(size: Theme.fontTiny, design: .monospaced))
                        .foregroundStyle(Theme.accent)
                }
            }

            if notifications.isEmpty {
                VStack(spacing: 4) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textMuted)
                    Text("No notifications")
                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(notifications) { notif in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: notif.icon)
                            .font(.system(size: 10))
                            .foregroundStyle(notif.color)
                            .frame(width: 18, height: 18)
                            .background(notif.color.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(notif.title)
                                .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Theme.textPrimary)
                            Text(notif.body)
                                .font(.system(size: Theme.fontTiny, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        Text(notif.time)
                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .padding(6)
                    .background(Theme.bgTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                }
            }
        }
        .padding(10)
        .background(Theme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.5), radius: 10, y: 4)
        .padding(.horizontal, 6)
        .padding(.top, 2)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let body: String
    let time: String

    static let samples: [NotificationItem] = [
        NotificationItem(icon: "brain.head.profile", color: Theme.accent, title: "AI Training Complete", body: "Model v2.1 finished with 98.7% accuracy", time: "2m"),
        NotificationItem(icon: "arrow.down.circle", color: Theme.success, title: "System Update", body: "N1OS 2.1.0 is ready to install", time: "15m"),
        NotificationItem(icon: "paperplane.fill", color: Color(red: 0.2, green: 0.6, blue: 1.0), title: "Telegram", body: "Alice: Hey, check out this new repo!", time: "1h"),
    ]
}
