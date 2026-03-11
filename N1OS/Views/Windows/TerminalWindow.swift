import SwiftUI

struct TerminalWindow: View {
    @Bindable var vm: TerminalVM

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                tabButton("Shell", tab: "shell")
                tabButton("Python", tab: "python")
                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.top, 4)

            // Output area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(vm.lines) { line in
                            Text(line.text)
                                .font(.system(size: Theme.fontSmall, design: .monospaced))
                                .foregroundStyle(line.color)
                                .textSelection(.enabled)
                                .id(line.id)
                        }
                    }
                    .padding(6)
                }
                .onChange(of: vm.lines.count) { _, _ in
                    if let last = vm.lines.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            // Input
            HStack(spacing: 4) {
                Text(vm.promptPrefix)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(Theme.success)
                    .lineLimit(1)

                TextField("", text: $vm.input)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        vm.executeCommand()
                    }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Theme.bgInput)
        }
        .background(Theme.bgPrimary)
    }

    func tabButton(_ title: String, tab: String) -> some View {
        Button {
            vm.currentTab = tab
            if tab == "python" && vm.currentTab != "python" {
                vm.lines.append(TerminalLine("Python 3.11.0 (N1OS)", color: Theme.accent))
                vm.lines.append(TerminalLine("Type help() for help, exit() to quit", color: Theme.textSecondary))
            }
        } label: {
            Text(title)
                .font(.system(size: Theme.fontTiny, weight: vm.currentTab == tab ? .bold : .regular, design: .monospaced))
                .foregroundStyle(vm.currentTab == tab ? Theme.accent : Theme.textMuted)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(vm.currentTab == tab ? Theme.accent.opacity(0.1) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
        }
    }
}
