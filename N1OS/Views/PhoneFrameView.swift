import SwiftUI

struct PhoneFrameView: View {
    @State private var desktop = DesktopVM()
    @State private var terminalVM = TerminalVM()
    @State private var aiChatVM = AIChatVM()
    @State private var filesVM = FilesVM()
    @State private var browserVM = BrowserVM()
    @State private var musicVM = MusicVM()
    @State private var notesVM = NotesVM()
    @State private var messagingVM = MessagingVM()
    @State private var calculatorVM = CalculatorVM()

    var body: some View {
        ZStack {
            // Bezel
            RoundedRectangle(cornerRadius: Theme.frameRadius)
                .fill(Theme.bezelColor)
                .frame(width: Theme.phoneWidth, height: Theme.phoneHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.frameRadius)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

            // Earpiece
            Capsule()
                .fill(Theme.earpiece)
                .frame(width: 40, height: 4)
                .offset(y: -(Theme.phoneHeight / 2 - 20))

            // Camera dot
            Circle()
                .fill(Theme.camera)
                .frame(width: 8, height: 8)
                .overlay(Circle().fill(Color.blue.opacity(0.3)).frame(width: 4, height: 4))
                .offset(x: -30, y: -(Theme.phoneHeight / 2 - 20))

            // Screen
            ZStack(alignment: .top) {
                Theme.bgPrimary

                VStack(spacing: 0) {
                    TopPanelView(desktop: desktop)

                    ZStack {
                        // Home screen (visible when no windows open)
                        HomeScreenView(desktop: desktop, musicVM: musicVM)

                        // Floating windows
                        ForEach(desktop.openWindows) { appId in
                            FloatingWindowView(
                                appId: appId,
                                desktop: desktop
                            ) {
                                windowContent(for: appId)
                            }
                            .zIndex(Double(desktop.windows[appId]?.zIndex ?? 0))
                        }

                        // Overlays
                        if desktop.showAppDrawer {
                            AppDrawerView(desktop: desktop)
                                .zIndex(9998)
                        }
                        if desktop.showQuickSettings {
                            QuickSettingsView(desktop: desktop)
                                .zIndex(9999)
                        }
                        if desktop.showNotifications {
                            NotificationsView(desktop: desktop)
                                .zIndex(9999)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .clipped()

                    DockView(desktop: desktop)
                }
            }
            .frame(width: Theme.screenWidth, height: Theme.screenHeight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.screenRadius))
        }
        .frame(width: Theme.phoneWidth, height: Theme.phoneHeight)
    }

    @ViewBuilder
    func windowContent(for appId: AppWindowID) -> some View {
        switch appId {
        case .terminal:
            TerminalWindow(vm: terminalVM)
        case .aiChat:
            AIChatWindow(vm: aiChatVM)
        case .files:
            FilesWindow(vm: filesVM)
        case .browser:
            BrowserWindow(vm: browserVM)
        case .settings:
            SettingsWindow()
        case .vscode:
            VSCodeWindow()
        case .music:
            MusicWindow(vm: musicVM)
        case .notes:
            NotesWindow(vm: notesVM)
        case .telegram:
            TelegramWindow(vm: messagingVM)
        case .wechat:
            WeChatWindow(vm: messagingVM)
        case .camera:
            CameraWindow()
        case .calculator:
            CalculatorWindow(vm: calculatorVM)
        case .systemMonitor:
            SystemMonitorWindow()
        case .recorder:
            RecorderWindow()
        }
    }
}
