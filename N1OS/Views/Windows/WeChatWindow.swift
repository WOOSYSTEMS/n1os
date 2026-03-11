import SwiftUI

struct WeChatWindow: View {
    @Bindable var vm: MessagingVM

    private let sidebarTabs = [
        ("bubble.left.fill", "chats"),
        ("person.2.fill", "contacts"),
        ("square.grid.2x2", "discover"),
        ("person.fill", "me"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar nav
            VStack(spacing: 8) {
                ForEach(sidebarTabs, id: \.1) { icon, tab in
                    Button {
                        vm.wechatSidebarTab = tab
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 11))
                            .foregroundStyle(vm.wechatSidebarTab == tab ? Theme.success : Theme.textMuted)
                    }
                }
                Spacer()
            }
            .frame(width: 28)
            .padding(.top, 8)
            .background(Theme.bgSecondary.opacity(0.8))

            Rectangle().fill(Theme.border).frame(width: 0.5)

            // Contact list
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(vm.wechatContacts.enumerated()), id: \.element.id) { index, contact in
                            Button {
                                vm.selectedWeChatIndex = index
                                vm.wechatContacts[index].unread = 0
                            } label: {
                                HStack(spacing: 5) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Theme.success.opacity(0.3))
                                            .frame(width: 22, height: 22)
                                        Text(contact.avatar)
                                            .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                                            .foregroundStyle(Theme.success)
                                    }
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(contact.name)
                                            .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(Theme.textPrimary)
                                            .lineLimit(1)
                                        Text(contact.lastMessage)
                                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                                            .foregroundStyle(Theme.textMuted)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(contact.time)
                                            .font(.system(size: 6, design: .monospaced))
                                            .foregroundStyle(Theme.textMuted)
                                        if contact.unread > 0 {
                                            Text("\(contact.unread)")
                                                .font(.system(size: 6, weight: .bold, design: .monospaced))
                                                .foregroundStyle(.white)
                                                .frame(width: 12, height: 12)
                                                .background(Theme.danger)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 3)
                                .background(index == vm.selectedWeChatIndex ? Theme.success.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 4)
                }
            }
            .frame(width: 90)
            .background(Theme.bgSecondary)

            Rectangle().fill(Theme.border).frame(width: 0.5)

            // Chat area
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(vm.selectedWeChatContact.name)
                        .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgSecondary)

                // Messages
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(vm.selectedWeChatContact.messages) { msg in
                            HStack {
                                if msg.isMe { Spacer(minLength: 16) }
                                VStack(alignment: msg.isMe ? .trailing : .leading, spacing: 1) {
                                    Text(msg.text)
                                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                                        .foregroundStyle(msg.isMe ? .white : Theme.textPrimary)
                                    Text(msg.time)
                                        .font(.system(size: 6, design: .monospaced))
                                        .foregroundStyle(msg.isMe ? .white.opacity(0.7) : Theme.textMuted)
                                }
                                .padding(5)
                                .background(msg.isMe ? Theme.success : Theme.bgTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                                if !msg.isMe { Spacer(minLength: 16) }
                            }
                        }
                    }
                    .padding(4)
                }

                // Input
                HStack(spacing: 4) {
                    TextField("Message...", text: $vm.messageInput)
                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .textFieldStyle(.plain)
                        .onSubmit { vm.sendWeChatMessage() }
                    Button {
                        vm.sendWeChatMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.success)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgInput)
            }
        }
    }
}
