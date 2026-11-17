import SwiftUI
import WebKit

// MARK: - BrowserTab

struct BrowserTab: Identifiable, Equatable {
    let id: UUID
    var url: URL?
    var title: String
    var favicon: UIImage?
    var snapshot: UIImage?
    var isLoading: Bool
    var loadProgress: Double
    var isPinned: Bool
    var isPrivate: Bool
    var lastAccessed: Date
    var webView: WKWebView?

    init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "Nueva pestaña",
        isPinned: Bool = false,
        isPrivate: Bool = false
    ) {
        self.id           = id
        self.url          = url
        self.title        = title
        self.isLoading    = false
        self.loadProgress = 0
        self.isPinned     = isPinned
        self.isPrivate    = isPrivate
        self.lastAccessed = Date()
    }

    static func == (lhs: BrowserTab, rhs: BrowserTab) -> Bool {
        lhs.id == rhs.id
    }

    var displayTitle: String {
        title.isEmpty ? (url?.host ?? "Nueva pestaña") : title
    }

    var displayHost: String {
        url?.host?.replacingOccurrences(of: "www.", with: "") ?? ""
    }

    var isSecure: Bool {
        url?.scheme == "https"
    }
}
