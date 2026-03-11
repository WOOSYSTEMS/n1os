import SwiftUI

struct BrowserWindow: View {
    @Bindable var vm: BrowserVM

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(Array(vm.tabs.enumerated()), id: \.element.id) { index, tab in
                        HStack(spacing: 3) {
                            Text(tab.title)
                                .font(.system(size: Theme.fontMicro, design: .monospaced))
                                .foregroundStyle(index == vm.activeTabIndex ? Theme.textPrimary : Theme.textMuted)
                                .lineLimit(1)

                            if vm.tabs.count > 1 {
                                Button {
                                    vm.closeTab(at: index)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 5, weight: .bold))
                                        .foregroundStyle(Theme.textMuted)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(index == vm.activeTabIndex ? Theme.bgTertiary : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                        .onTapGesture {
                            vm.activeTabIndex = index
                        }
                    }

                    Button {
                        vm.addTab()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 8))
                            .foregroundStyle(Theme.textMuted)
                            .padding(3)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 20)
            .background(Theme.bgSecondary)

            if vm.activeTab.isHome {
                homePage
            } else {
                sitePage
            }
        }
    }

    var homePage: some View {
        VStack(spacing: 8) {
            Spacer()

            // Search bar
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.textMuted)
                TextField("Search or enter URL", text: $vm.searchText)
                    .font(.system(size: Theme.fontSmall, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        if !vm.searchText.isEmpty {
                            vm.navigate(to: vm.searchText)
                        }
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Theme.bgInput)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
            .padding(.horizontal, 16)

            // Bookmarks
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(vm.bookmarks) { bookmark in
                    Button {
                        vm.navigate(to: bookmark.url)
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                    .fill(bookmark.color.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: bookmark.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(bookmark.color)
                            }
                            Text(bookmark.title)
                                .font(.system(size: Theme.fontMicro, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    var sitePage: some View {
        VStack(spacing: 0) {
            // URL bar
            HStack(spacing: 4) {
                Button {
                    vm.goHome()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(Theme.success)
                    Text(vm.activeTab.url)
                        .font(.system(size: Theme.fontTiny, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)

            // Page content
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(vm.pageContent(for: vm.activeTab.url).enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading, spacing: 2) {
                            if !item.0.isEmpty {
                                Text(item.0)
                                    .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                                    .foregroundStyle(item.2)
                            }
                            Text(item.1)
                                .font(.system(size: Theme.fontSmall, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                    }
                }
                .padding(6)
            }
        }
    }
}
