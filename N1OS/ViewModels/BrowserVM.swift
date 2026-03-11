import SwiftUI

struct BrowserTab: Identifiable {
    let id = UUID()
    var title: String
    var url: String
    var isHome: Bool
}

struct Bookmark: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let url: String
}

@Observable
class BrowserVM {
    var tabs: [BrowserTab] = [
        BrowserTab(title: "New Tab", url: "", isHome: true)
    ]
    var activeTabIndex: Int = 0
    var searchText: String = ""

    var bookmarks: [Bookmark] = [
        Bookmark(title: "GitHub", icon: "chevron.left.forwardslash.chevron.right", color: Theme.textPrimary, url: "github.com"),
        Bookmark(title: "Reddit", icon: "bubble.left.fill", color: Color.orange, url: "reddit.com"),
        Bookmark(title: "Wikipedia", icon: "book.fill", color: Theme.textSecondary, url: "wikipedia.org"),
        Bookmark(title: "HN", icon: "y.square.fill", color: Color.orange, url: "news.ycombinator.com"),
        Bookmark(title: "Docs", icon: "doc.text.fill", color: Theme.accent, url: "docs.n1os.dev"),
        Bookmark(title: "Pine64", icon: "pine.fill", color: Theme.success, url: "pine64.org"),
    ]

    var activeTab: BrowserTab {
        get { tabs[safe: activeTabIndex] ?? tabs[0] }
        set {
            if tabs.indices.contains(activeTabIndex) {
                tabs[activeTabIndex] = newValue
            }
        }
    }

    func navigate(to url: String) {
        tabs[activeTabIndex].url = url
        tabs[activeTabIndex].title = siteName(for: url)
        tabs[activeTabIndex].isHome = false
        searchText = ""
    }

    func goHome() {
        tabs[activeTabIndex].isHome = true
        tabs[activeTabIndex].title = "New Tab"
        tabs[activeTabIndex].url = ""
        searchText = ""
    }

    func addTab() {
        let tab = BrowserTab(title: "New Tab", url: "", isHome: true)
        tabs.append(tab)
        activeTabIndex = tabs.count - 1
    }

    func closeTab(at index: Int) {
        guard tabs.count > 1 else { return }
        tabs.remove(at: index)
        if activeTabIndex >= tabs.count {
            activeTabIndex = tabs.count - 1
        }
    }

    func siteName(for url: String) -> String {
        if url.contains("github") { return "GitHub" }
        if url.contains("reddit") { return "Reddit" }
        if url.contains("wikipedia") { return "Wikipedia" }
        if url.contains("ycombinator") { return "Hacker News" }
        if url.contains("docs") { return "N1OS Docs" }
        if url.contains("pine64") { return "Pine64" }
        return url
    }

    func pageContent(for url: String) -> [(String, String, Color)] {
        if url.contains("github") {
            return [
                ("GitHub", "Where the world builds software", Theme.textPrimary),
                ("Trending", "pine64/pinephone-kernel ★ 2.4k", Theme.accent),
                ("", "n1os/neural-engine ★ 1.8k", Theme.accent),
                ("", "ollama/ollama ★ 45.2k", Theme.accent),
            ]
        }
        if url.contains("reddit") {
            return [
                ("r/pinephone", "Community for PinePhone users", Theme.textPrimary),
                ("Hot", "Finally got N1OS running smoothly!", Theme.warning),
                ("", "Best Ollama models for ARM64?", Theme.textSecondary),
                ("", "Battery optimization tips", Theme.textSecondary),
            ]
        }
        if url.contains("wikipedia") {
            return [
                ("Wikipedia", "The Free Encyclopedia", Theme.textPrimary),
                ("Featured", "PinePhone is a smartphone by Pine64", Theme.textSecondary),
                ("", "It features an Allwinner A64 SoC", Theme.textSecondary),
                ("", "with 3GB RAM and runs mainline Linux", Theme.textSecondary),
            ]
        }
        if url.contains("ycombinator") {
            return [
                ("Hacker News", "Links for the curious", Theme.warning),
                ("1.", "Show HN: N1OS – Linux phone OS with local AI", Theme.textPrimary),
                ("2.", "ARM vs x86 for edge AI inference", Theme.textPrimary),
                ("3.", "PinePhone Pro gets mainline kernel support", Theme.textPrimary),
            ]
        }
        if url.contains("docs") {
            return [
                ("N1OS Documentation", "v2.1.0", Theme.accent),
                ("Getting Started", "Installation and setup guide", Theme.textSecondary),
                ("API Reference", "Neural Engine API docs", Theme.textSecondary),
                ("Customization", "Themes, widgets, shortcuts", Theme.textSecondary),
            ]
        }
        if url.contains("pine64") {
            return [
                ("Pine64", "Open source hardware", Theme.success),
                ("PinePhone", "The Linux smartphone", Theme.textPrimary),
                ("PineTab", "Linux tablet", Theme.textSecondary),
                ("PineBook Pro", "ARM laptop", Theme.textSecondary),
            ]
        }
        return [("Page", url, Theme.textPrimary)]
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
