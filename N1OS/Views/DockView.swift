import SwiftUI

struct DockView: View {
    let desktop: DesktopVM

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppWindowID.dockApps) { app in
                Button {
                    desktop.toggleWindow(app)
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: app.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(desktop.isActive(app) ? app.accentColor : Theme.textSecondary)
                            .frame(width: 32, height: 28)

                        // Running indicator
                        Circle()
                            .fill(desktop.isRunning(app) ? app.accentColor : Color.clear)
                            .frame(width: 3, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // App drawer button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    desktop.showAppDrawer.toggle()
                }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 14))
                        .foregroundStyle(desktop.showAppDrawer ? Theme.accent : Theme.textSecondary)
                        .frame(width: 32, height: 28)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 3, height: 3)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .frame(height: Theme.dockHeight)
        .background(
            Theme.bgSecondary
                .overlay(
                    Rectangle()
                        .fill(Theme.border)
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }
}
