import SwiftUI

struct TelegramWindow: View {
    @Bindable var vm: MessagingVM

    var body: some View {
        HStack(spacing: 0) {
            // Contact list
            VStack(spacing: 0) {
                Text("Chats")
                    .font(.system(size: Theme.fontTiny, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)

                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(vm.telegramContacts.enumerated()), id: \.element.id) { index, contact in
                            Button {
                                vm.selectedTelegramIndex = index
                                vm.telegramContacts[index].unread = 0
                            } label: {
                                HStack(spacing: 6) {
                                    // Avatar
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3))
                                            .frame(width: 24, height: 24)
                                        Text(contact.avatar)
                                            .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                                            .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 1.0))
                                    }

                                    VStack(alignment: .leading, spacing: 1) {
                                        HStack {
                                            Text(contact.name)
                                                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                                                .foregroundStyle(Theme.textPrimary)
                                                .lineLimit(1)
                                            Spacer()
                                            Text(contact.time)
                                                .font(.system(size: 6, design: .monospaced))
                                                .foregroundStyle(Theme.textMuted)
                                        }
                                        HStack {
                                            Text(contact.lastMessage)
                                                .font(.system(size: Theme.fontMicro, design: .monospaced))
                                                .foregroundStyle(Theme.textMuted)
                                                .lineLimit(1)
                                            Spacer()
                                            if contact.unread > 0 {
                                                Text("\(contact.unread)")
                                                    .font(.system(size: 6, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(.white)
                                                    .frame(width: 12, height: 12)
                                                    .background(Color(red: 0.2, green: 0.6, blue: 1.0))
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 3)
                                .background(index == vm.selectedTelegramIndex ? Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .frame(width: 100)
            .background(Theme.bgSecondary)

            Rectangle().fill(Theme.border).frame(width: 0.5)

            // Chat area
            VStack(spacing: 0) {
                // Chat header
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text(vm.selectedTelegramContact.avatar)
                            .font(.system(size: Theme.fontTiny, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 1.0))
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(vm.selectedTelegramContact.name)
                            .font(.system(size: Theme.fontSmall, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Theme.textPrimary)
                        Text("online")
                            .font(.system(size: Theme.fontMicro, design: .monospaced))
                            .foregroundStyle(Theme.success)
                    }
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgSecondary)

                // Messages
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(vm.selectedTelegramContact.messages) { msg in
                            HStack {
                                if msg.isMe { Spacer(minLength: 20) }
                                VStack(alignment: msg.isMe ? .trailing : .leading, spacing: 1) {
                                    Text(msg.text)
                                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                                        .foregroundStyle(msg.isMe ? Theme.bgPrimary : Theme.textPrimary)
                                    Text(msg.time)
                                        .font(.system(size: 6, design: .monospaced))
                                        .foregroundStyle(msg.isMe ? Theme.bgPrimary.opacity(0.7) : Theme.textMuted)
                                }
                                .padding(5)
                                .background(msg.isMe ? Color(red: 0.2, green: 0.6, blue: 1.0) : Theme.bgTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                                if !msg.isMe { Spacer(minLength: 20) }
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
                        .onSubmit { vm.sendTelegramMessage() }
                    Button {
                        vm.sendTelegramMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 1.0))
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgInput)
            }
        }
    }
}
