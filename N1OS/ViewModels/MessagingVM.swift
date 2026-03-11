import SwiftUI

@Observable
class MessagingVM {
    // MARK: - Telegram
    var telegramContacts: [Contact] = [
        Contact(
            name: "Alice Chen",
            avatar: "A",
            lastMessage: "Check out this new repo!",
            time: "14:32",
            unread: 2,
            messages: [
                ContactMessage(text: "Hey! Have you seen the new PinePhone kernel update?", isMe: false, time: "14:28"),
                ContactMessage(text: "Not yet, what's new?", isMe: true, time: "14:29"),
                ContactMessage(text: "Mali GPU improvements and better power management", isMe: false, time: "14:30"),
                ContactMessage(text: "Check out this new repo!", isMe: false, time: "14:32"),
            ]
        ),
        Contact(
            name: "Bob Kumar",
            avatar: "B",
            lastMessage: "The model runs great on ARM!",
            time: "13:15",
            unread: 0,
            messages: [
                ContactMessage(text: "How's the Ollama setup going?", isMe: true, time: "13:10"),
                ContactMessage(text: "Got it working with llama3.2", isMe: false, time: "13:12"),
                ContactMessage(text: "The model runs great on ARM!", isMe: false, time: "13:15"),
            ]
        ),
        Contact(
            name: "Dev Group",
            avatar: "D",
            lastMessage: "Meeting at 3pm tomorrow",
            time: "12:00",
            unread: 5,
            messages: [
                ContactMessage(text: "Sprint review moved to Thursday", isMe: false, time: "11:45"),
                ContactMessage(text: "Got it, thanks", isMe: true, time: "11:50"),
                ContactMessage(text: "Meeting at 3pm tomorrow", isMe: false, time: "12:00"),
            ]
        ),
    ]

    var selectedTelegramIndex: Int = 0

    var selectedTelegramContact: Contact {
        get { telegramContacts[selectedTelegramIndex] }
        set { telegramContacts[selectedTelegramIndex] = newValue }
    }

    // MARK: - WeChat
    var wechatContacts: [Contact] = [
        Contact(
            name: "Wei Zhang",
            avatar: "W",
            lastMessage: "See you at the conference!",
            time: "15:10",
            unread: 1,
            messages: [
                ContactMessage(text: "Are you coming to the Linux Phone meetup?", isMe: false, time: "15:05"),
                ContactMessage(text: "Yes! I'll bring my PinePhone", isMe: true, time: "15:07"),
                ContactMessage(text: "See you at the conference!", isMe: false, time: "15:10"),
            ]
        ),
        Contact(
            name: "Li Ming",
            avatar: "L",
            lastMessage: "The PCB design looks good",
            time: "11:30",
            unread: 0,
            messages: [
                ContactMessage(text: "Sent you the schematics", isMe: true, time: "11:20"),
                ContactMessage(text: "The PCB design looks good", isMe: false, time: "11:30"),
            ]
        ),
        Contact(
            name: "Tech Chat",
            avatar: "T",
            lastMessage: "New RISC-V boards in stock",
            time: "10:45",
            unread: 3,
            messages: [
                ContactMessage(text: "Anyone tried the new firmware?", isMe: false, time: "10:30"),
                ContactMessage(text: "Not yet, waiting for stable", isMe: true, time: "10:35"),
                ContactMessage(text: "New RISC-V boards in stock", isMe: false, time: "10:45"),
            ]
        ),
        Contact(
            name: "Xiao Yu",
            avatar: "X",
            lastMessage: "Thanks for the help!",
            time: "09:20",
            unread: 0,
            messages: [
                ContactMessage(text: "How do I flash N1OS?", isMe: false, time: "09:10"),
                ContactMessage(text: "Use dd to write the image to SD card", isMe: true, time: "09:15"),
                ContactMessage(text: "Thanks for the help!", isMe: false, time: "09:20"),
            ]
        ),
    ]

    var selectedWeChatIndex: Int = 0
    var wechatSidebarTab: String = "chats"

    var selectedWeChatContact: Contact {
        get { wechatContacts[selectedWeChatIndex] }
        set { wechatContacts[selectedWeChatIndex] = newValue }
    }

    // MARK: - Shared
    var messageInput: String = ""

    func sendTelegramMessage() {
        let text = messageInput.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let msg = ContactMessage(text: text, isMe: true, time: currentTimeString)
        telegramContacts[selectedTelegramIndex].messages.append(msg)
        telegramContacts[selectedTelegramIndex].lastMessage = text
        messageInput = ""
    }

    func sendWeChatMessage() {
        let text = messageInput.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let msg = ContactMessage(text: text, isMe: true, time: currentTimeString)
        wechatContacts[selectedWeChatIndex].messages.append(msg)
        wechatContacts[selectedWeChatIndex].lastMessage = text
        messageInput = ""
    }

    private var currentTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }
}
