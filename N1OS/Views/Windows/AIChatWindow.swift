import SwiftUI

struct AIChatWindow: View {
    @Bindable var vm: AIChatVM

    var body: some View {
        VStack(spacing: 0) {
            // Model selector bar
            HStack(spacing: 4) {
                Circle()
                    .fill(Theme.success)
                    .frame(width: 5, height: 5)
                Picker("Model", selection: $vm.selectedModel) {
                    ForEach(vm.models, id: \.self) { model in
                        Text(model)
                            .font(.system(size: Theme.fontTiny, design: .monospaced))
                            .tag(model)
                    }
                }
                .pickerStyle(.menu)
                .scaleEffect(0.75)
                .frame(height: 20)

                Spacer()

                Text(vm.tokenInfo)
                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Theme.bgSecondary)

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(vm.messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }

                        if vm.isTyping {
                            typingIndicator
                                .id("typing")
                        }
                    }
                    .padding(6)
                }
                .onChange(of: vm.messages.count) { _, _ in
                    if let last = vm.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onChange(of: vm.isTyping) { _, newVal in
                    if newVal {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }

            // Input
            HStack(spacing: 4) {
                TextField("Ask anything...", text: $vm.input)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .textFieldStyle(.plain)
                    .onSubmit { vm.sendMessage() }

                Button {
                    vm.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.accent)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Theme.bgInput)
        }
    }

    func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 30) }

            VStack(alignment: .leading, spacing: 4) {
                Text(msg.content)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(msg.isUser ? Theme.bgPrimary : Theme.textPrimary)

                if msg.hasCodeBlock, let code = msg.codeContent {
                    VStack(alignment: .leading, spacing: 2) {
                        if let lang = msg.codeLanguage {
                            Text(lang)
                                .font(.system(size: Theme.fontMicro, weight: .bold, design: .monospaced))
                                .foregroundStyle(Theme.accent)
                        }
                        Text(code)
                            .font(.system(size: Theme.fontTiny, design: .monospaced))
                            .foregroundStyle(Theme.success)
                            .padding(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.bgPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                    }
                }
            }
            .padding(6)
            .background(msg.isUser ? Theme.accent : Theme.bgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))

            if !msg.isUser { Spacer(minLength: 30) }
        }
    }

    var typingIndicator: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 4, height: 4)
                    .opacity(0.6)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(i) * 0.15),
                        value: vm.isTyping
                    )
            }
        }
        .padding(6)
        .background(Theme.bgTertiary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
    }
}
