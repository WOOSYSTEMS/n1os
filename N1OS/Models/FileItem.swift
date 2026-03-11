import Foundation

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let isFolder: Bool
    let size: String
    let modified: String
    let icon: String
    var children: [FileItem]?

    init(name: String, isFolder: Bool, size: String = "", modified: String = "2025-01-15", icon: String? = nil, children: [FileItem]? = nil) {
        self.name = name
        self.isFolder = isFolder
        self.size = size
        self.modified = modified
        self.icon = icon ?? (isFolder ? "folder.fill" : FileItem.iconForFile(name))
        self.children = children
    }

    static func iconForFile(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "py": return "chevron.left.forwardslash.chevron.right"
        case "js", "ts": return "chevron.left.forwardslash.chevron.right"
        case "swift": return "swift"
        case "md", "txt": return "doc.text"
        case "pdf": return "doc.richtext"
        case "png", "jpg", "jpeg": return "photo"
        case "mp3", "wav": return "music.note"
        case "mp4", "mov": return "film"
        case "zip", "tar": return "archivebox"
        default: return "doc"
        }
    }
}
