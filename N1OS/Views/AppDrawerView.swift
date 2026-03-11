import SwiftUI

struct AppDrawerView: View {
    let desktop: DesktopVM

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Theme.textMuted)
                .frame(width: 32, height: 3)
                .padding(.top, 8)
                .padding(.bottom, 6)

            Text("Applications")
                .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .padding(.bottom, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AppWindowID.allCases) { app in
                        Button {
                            desktop.openWindow(app)
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                        .fill(app.accentColor.opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: app.icon)
                                        .font(.system(size: 14))
                                        .foregroundStyle(app.accentColor)
                                }
                                Text(app.title)
                                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgPrimary.opacity(0.97))
        .onTapGesture { } // prevent pass-through
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 60 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            desktop.showAppDrawer = false
                        }
                    }
                }
        )
    }
}
