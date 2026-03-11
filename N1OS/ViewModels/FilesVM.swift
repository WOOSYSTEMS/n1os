import SwiftUI

@Observable
class FilesVM {
    var currentPath: [String] = ["Home"]
    var selectedSidebar: String = "Home"

    var filesystem: [String: [FileItem]] = [
        "Home": [
            FileItem(name: "Documents", isFolder: true),
            FileItem(name: "Downloads", isFolder: true),
            FileItem(name: "Pictures", isFolder: true),
            FileItem(name: "Music", isFolder: true),
            FileItem(name: "neural_net.py", isFolder: false, size: "4.2 KB"),
            FileItem(name: "README.md", isFolder: false, size: "1.8 KB"),
            FileItem(name: "setup.sh", isFolder: false, size: "0.5 KB"),
            FileItem(name: "data.csv", isFolder: false, size: "12.4 KB"),
        ],
        "Documents": [
            FileItem(name: "Projects", isFolder: true),
            FileItem(name: "report.pdf", isFolder: false, size: "2.1 MB"),
            FileItem(name: "notes.md", isFolder: false, size: "3.2 KB"),
            FileItem(name: "budget.csv", isFolder: false, size: "8.7 KB"),
        ],
        "Downloads": [
            FileItem(name: "n1os-update.tar.gz", isFolder: false, size: "156 MB"),
            FileItem(name: "wallpaper.png", isFolder: false, size: "4.8 MB"),
            FileItem(name: "ebook.pdf", isFolder: false, size: "12 MB"),
        ],
        "Pictures": [
            FileItem(name: "Screenshots", isFolder: true),
            FileItem(name: "photo_001.png", isFolder: false, size: "3.2 MB"),
            FileItem(name: "photo_002.jpg", isFolder: false, size: "2.8 MB"),
            FileItem(name: "diagram.svg", isFolder: false, size: "42 KB"),
        ],
        "Music": [
            FileItem(name: "digital_dreams.mp3", isFolder: false, size: "8.2 MB"),
            FileItem(name: "quantum_pulse.mp3", isFolder: false, size: "6.7 MB"),
            FileItem(name: "neon_cascade.flac", isFolder: false, size: "32 MB"),
        ],
        "Projects": [
            FileItem(name: "n1-kernel", isFolder: true),
            FileItem(name: "ml-models", isFolder: true),
            FileItem(name: "webapp", isFolder: true),
        ],
        "Screenshots": [
            FileItem(name: "screen_01.png", isFolder: false, size: "1.2 MB"),
            FileItem(name: "screen_02.png", isFolder: false, size: "980 KB"),
        ],
        "Trash": [
            FileItem(name: "old_config.bak", isFolder: false, size: "2 KB"),
            FileItem(name: "temp_data.tmp", isFolder: false, size: "64 KB"),
        ],
    ]

    var currentItems: [FileItem] {
        let key = currentPath.last ?? "Home"
        return filesystem[key] ?? []
    }

    var breadcrumb: String {
        "/" + currentPath.joined(separator: "/")
    }

    func navigateTo(_ folder: String) {
        currentPath.append(folder)
    }

    func goBack() {
        if currentPath.count > 1 {
            currentPath.removeLast()
        }
    }

    func selectSidebar(_ item: String) {
        selectedSidebar = item
        currentPath = [item]
    }

    var sidebarItems: [(String, String)] {
        [
            ("Home", "house.fill"),
            ("Documents", "doc.fill"),
            ("Downloads", "arrow.down.circle.fill"),
            ("Pictures", "photo.fill"),
            ("Trash", "trash.fill"),
        ]
    }
}
