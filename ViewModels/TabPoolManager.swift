import Foundation
import WebKit
import UIKit

// MARK: - TabPoolManager (In-Memory Multi-Instance WebKit Pool)

public final class TabPoolManager: @unchecked Sendable {
    public static let shared = TabPoolManager()

    private var pool: [UUID: WKWebView] = [:]
    private let lock = NSLock()

    private lazy var defaultConfiguration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        if let ruleList = AntiTrackerEngine.shared.ruleList {
            config.userContentController.add(ruleList)
        }
        return config
    }()

    private lazy var privateConfiguration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .nonPersistent()

        if let ruleList = AntiTrackerEngine.shared.ruleList {
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

        // SOLUCIÓN DEFINITIVA A TOQUES Y GESTOS:
        // 1. Gestos nativos de navegación lateral de Safari (sin capas transparentes encima)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.keyboardDismissMode = .onDrag
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
