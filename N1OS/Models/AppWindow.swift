import SwiftUI

enum AppWindowID: String, CaseIterable, Identifiable {
    case terminal
    case aiChat
    case files
    case browser
    case settings
    case vscode
    case music
    case notes
    case telegram
    case wechat
    case camera
    case calculator
    case systemMonitor
    case recorder

    var id: String { rawValue }

    var title: String {
        switch self {
        case .terminal: return "Terminal"
        case .aiChat: return "AI Chat"
        case .files: return "Files"
        case .browser: return "Browser"
        case .settings: return "Settings"
        case .vscode: return "VS Code"
        case .music: return "Music"
        case .notes: return "Notes"
        case .telegram: return "Telegram"
        case .wechat: return "WeChat"
        case .camera: return "Camera"
        case .calculator: return "Calculator"
        case .systemMonitor: return "System Monitor"
        case .recorder: return "Recorder"
        }
    }

    var icon: String {
        switch self {
        case .terminal: return "terminal"
        case .aiChat: return "brain.head.profile"
        case .files: return "folder.fill"
        case .browser: return "globe"
        case .settings: return "gearshape.fill"
        case .vscode: return "chevron.left.forwardslash.chevron.right"
        case .music: return "music.note"
        case .notes: return "note.text"
        case .telegram: return "paperplane.fill"
        case .wechat: return "message.fill"
        case .camera: return "camera.fill"
        case .calculator: return "plus.forwardslash.minus"
        case .systemMonitor: return "cpu"
        case .recorder: return "mic.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .terminal: return Theme.success
        case .aiChat: return Theme.accent
        case .files: return Theme.warning
        case .browser: return Theme.accent
        case .settings: return Theme.textSecondary
        case .vscode: return Theme.accent
        case .music: return Theme.purple
        case .notes: return Theme.warning
        case .telegram: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .wechat: return Theme.success
        case .camera: return Theme.danger
        case .calculator: return Theme.accent
        case .systemMonitor: return Theme.success
        case .recorder: return Theme.danger
        }
    }

    static var dockApps: [AppWindowID] {
        [.terminal, .files, .browser, .settings, .music]
    }
}

struct WindowState {
    var isOpen: Bool = false
    var isMinimized: Bool = false
    var isMaximized: Bool = false
    var zIndex: Int = 0
    var position: CGPoint = CGPoint(x: 8, y: 30)
}
