import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let hasCodeBlock: Bool
    let codeContent: String?
    let codeLanguage: String?

    init(content: String, isUser: Bool, timestamp: Date = Date(), hasCodeBlock: Bool = false, codeContent: String? = nil, codeLanguage: String? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.hasCodeBlock = hasCodeBlock
        self.codeContent = codeContent
        self.codeLanguage = codeLanguage
    }
}

struct ContactMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    var lastMessage: String
    let time: String
    var unread: Int
    var messages: [ContactMessage]
}
