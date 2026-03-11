import SwiftUI

struct FilesWindow: View {
    @Bindable var vm: FilesVM

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 2) {
                ForEach(vm.sidebarItems, id: \.0) { name, icon in
                    Button {
                        vm.selectSidebar(name)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.system(size: 8))
                                .foregroundStyle(vm.selectedSidebar == name ? Theme.accent : Theme.textMuted)
                                .frame(width: 14)
                            Text(name)
                                .font(.system(size: Theme.fontTiny, design: .monospaced))
                                .foregroundStyle(vm.selectedSidebar == name ? Theme.textPrimary : Theme.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(vm.selectedSidebar == name ? Theme.accent.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                    }
                }
                Spacer()
            }
            .frame(width: 70)
            .padding(4)
            .background(Theme.bgSecondary)

            // Divider
            Rectangle()
                .fill(Theme.border)
                .frame(width: 0.5)

            // Content area
            VStack(spacing: 0) {
                // Breadcrumb + back
                HStack(spacing: 4) {
                    if vm.currentPath.count > 1 {
                        Button {
                            vm.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    Text(vm.breadcrumb)
                        .font(.system(size: Theme.fontTiny, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgSecondary)

                // File grid
                ScrollView {
                    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(vm.currentItems) { item in
                            Button {
                                if item.isFolder {
                                    vm.navigateTo(item.name)
                                }
                            } label: {
                                VStack(spacing: 3) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(item.isFolder ? Theme.warning : Theme.accent)
                                    Text(item.name)
                                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                                        .foregroundStyle(Theme.textPrimary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    if !item.size.isEmpty {
                                        Text(item.size)
                                            .font(.system(size: 6, design: .monospaced))
                                            .foregroundStyle(Theme.textMuted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Theme.bgCard)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                            }
                        }
                    }
                    .padding(6)
                }
            }
        }
    }
}
