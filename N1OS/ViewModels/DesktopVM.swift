import SwiftUI

@Observable
class DesktopVM {
    var windows: [AppWindowID: WindowState] = {
        var dict = [AppWindowID: WindowState]()
        for app in AppWindowID.allCases {
            dict[app] = WindowState()
        }
        return dict
    }()

    var nextZIndex: Int = 1
    var showAppDrawer = false
    var showQuickSettings = false
    var showNotifications = false

    var openWindows: [AppWindowID] {
        AppWindowID.allCases
            .filter { windows[$0]?.isOpen == true && windows[$0]?.isMinimized == false }
            .sorted { (windows[$0]?.zIndex ?? 0) < (windows[$1]?.zIndex ?? 0) }
    }

    var hasOpenWindows: Bool {
        AppWindowID.allCases.contains { windows[$0]?.isOpen == true && windows[$0]?.isMinimized == false }
    }

    func openWindow(_ id: AppWindowID) {
        windows[id]?.isOpen = true
        windows[id]?.isMinimized = false
        bringToFront(id)
        showAppDrawer = false
    }

    func closeWindow(_ id: AppWindowID) {
        windows[id]?.isOpen = false
        windows[id]?.isMinimized = false
        windows[id]?.isMaximized = false
    }

    func minimizeWindow(_ id: AppWindowID) {
        windows[id]?.isMinimized = true
    }

    func toggleMaximize(_ id: AppWindowID) {
        windows[id]?.isMaximized.toggle()
        bringToFront(id)
    }

    func bringToFront(_ id: AppWindowID) {
        windows[id]?.zIndex = nextZIndex
        nextZIndex += 1
    }

    func isRunning(_ id: AppWindowID) -> Bool {
        windows[id]?.isOpen == true
    }

    func isActive(_ id: AppWindowID) -> Bool {
        guard let state = windows[id], state.isOpen, !state.isMinimized else { return false }
        let maxZ = openWindows.compactMap { windows[$0]?.zIndex }.max() ?? 0
        return state.zIndex == maxZ
    }

    func toggleWindow(_ id: AppWindowID) {
        if windows[id]?.isOpen == true {
            if windows[id]?.isMinimized == true {
                windows[id]?.isMinimized = false
                bringToFront(id)
            } else if isActive(id) {
                minimizeWindow(id)
            } else {
                bringToFront(id)
            }
        } else {
            openWindow(id)
        }
    }

    func updatePosition(_ id: AppWindowID, _ pos: CGPoint) {
        windows[id]?.position = pos
    }
}
