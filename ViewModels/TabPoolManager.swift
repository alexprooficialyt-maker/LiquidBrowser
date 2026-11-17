import Foundation
import WebKit
import UIKit

public struct TabRuntimeState: @unchecked Sendable {
    public let tabID: UUID
    public let webView: WKWebView
    public var title: String
    public var currentURL: URL?
    public var progress: Double
    public var isLoading: Bool
    public var canGoBack: Bool
    public var canGoForward: Bool
    public var isSecure: Bool
    public var blockedTrackersCount: Int

    public init(
        tabID: UUID,
        webView: WKWebView,
        title: String = "Nueva Pestaña",
        currentURL: URL? = nil,
        progress: Double = 0.0,
        isLoading: Bool = false,
        canGoBack: Bool = false,
        canGoForward: Bool = false,
        isSecure: Bool = false,
        blockedTrackersCount: Int = 0
    ) {
        self.tabID = tabID
        self.webView = webView
        self.title = title
        self.currentURL = currentURL
        self.progress = progress
        self.isLoading = isLoading
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.isSecure = isSecure
        self.blockedTrackersCount = blockedTrackersCount
    }
}

public final class TabPoolManager: @unchecked Sendable {
    public static let shared = TabPoolManager()

    private var pool: [UUID: WKWebView] = [:]
    private let lock = NSLock()

    private lazy var defaultConfiguration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        if let ruleList = AdBlockerRuleEngine.shared.ruleList {
            config.userContentController.add(ruleList)
        }
        return config
    }()

    private lazy var privateConfiguration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .nonPersistent()

        if let ruleList = AdBlockerRuleEngine.shared.ruleList {
            config.userContentController.add(ruleList)
        }
        return config
    }()

    private init() {}

    public func webView(for tab: TabModel) -> WKWebView {
        lock.lock()
        defer { lock.unlock() }

        if let existing = pool[tab.id] {
            return existing
        }

        let config = tab.isPrivate ? privateConfiguration : defaultConfiguration
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        pool[tab.id] = webView
        return webView
    }

    public func removeWebView(for tabID: UUID) {
        lock.lock()
        let wv = pool.removeValue(forKey: tabID)
        lock.unlock()

        wv?.stopLoading()
        wv?.navigationDelegate = nil
        wv?.uiDelegate = nil
        wv?.removeFromSuperview()
    }

    public func clearAllNonPinned(pinnedIDs: Set<UUID>) {
        lock.lock()
        let toRemove = pool.keys.filter { !pinnedIDs.contains($0) }
        for id in toRemove {
            let wv = pool.removeValue(forKey: id)
            wv?.stopLoading()
            wv?.navigationDelegate = nil
            wv?.uiDelegate = nil
            wv?.removeFromSuperview()
        }
        lock.unlock()
    }

    public func clearAll() {
        lock.lock()
        for (_, wv) in pool {
            wv.stopLoading()
            wv.navigationDelegate = nil
            wv.uiDelegate = nil
            wv.removeFromSuperview()
        }
        pool.removeAll()
        lock.unlock()
    }
}
