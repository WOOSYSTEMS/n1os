import SwiftUI

struct FloatingWindowView<Content: View>: View {
    let appId: AppWindowID
    let desktop: DesktopVM
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGSize = .zero

    private var state: WindowState {
        desktop.windows[appId] ?? WindowState()
    }

    private var isMaximized: Bool { state.isMaximized }

    var body: some View {
        let windowW: CGFloat = isMaximized ? Theme.screenWidth : Theme.windowWidth
        let windowH: CGFloat = isMaximized ? (Theme.screenHeight - Theme.topPanelHeight - Theme.dockHeight) : Theme.windowHeight

        VStack(spacing: 0) {
            // Header bar
            HStack(spacing: 0) {
                Image(systemName: appId.icon)
                    .font(.system(size: 8))
                    .foregroundStyle(appId.accentColor)
                    .frame(width: 16)

                Text(appId.title)
                    .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    // Minimize
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            desktop.minimizeWindow(appId)
                        }
                    } label: {
                        Circle()
                            .fill(Theme.minBtn)
                            .frame(width: 8, height: 8)
                    }

                    // Maximize
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            desktop.toggleMaximize(appId)
                        }
                    } label: {
                        Circle()
                            .fill(Theme.maxBtn)
                            .frame(width: 8, height: 8)
                    }

                    // Close
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            desktop.closeWindow(appId)
                        }
                    } label: {
                        Circle()
                            .fill(Theme.closeBtn)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Theme.windowHeader)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isMaximized {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        if !isMaximized {
                            let currentPos = state.position
                            let newPos = CGPoint(
                                x: currentPos.x + value.translation.width,
                                y: currentPos.y + value.translation.height
                            )
                            desktop.updatePosition(appId, newPos)
                            dragOffset = .zero
                        }
                    }
            )
            .onTapGesture {
                desktop.bringToFront(appId)
            }

            // Body
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.windowBody)
                .clipped()
        }
        .frame(width: windowW, height: windowH)
        .clipShape(RoundedRectangle(cornerRadius: isMaximized ? 0 : Theme.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: isMaximized ? 0 : Theme.radiusLarge)
                .stroke(Theme.border, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.4), radius: isMaximized ? 0 : 8, y: 4)
        .offset(
            x: isMaximized ? 0 : state.position.x - Theme.screenWidth / 2 + windowW / 2 + dragOffset.width,
            y: isMaximized ? 0 : state.position.y - (Theme.screenHeight - Theme.topPanelHeight - Theme.dockHeight) / 2 + windowH / 2 + dragOffset.height
        )
    }
}
