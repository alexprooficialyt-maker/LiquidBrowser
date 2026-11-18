import Foundation
import WebKit
import UIKit

// MARK: - TabPoolManager (In-Memory Multi-Instance WebKit Pool & Apple-Certified Frame Engine)

public final class TabPoolManager: @unchecked Sendable {
    public static let shared = TabPoolManager()

    private var pool: [UUID: WKWebView] = [:]
    private let lock = NSLock()

    /// User-Agent oficial e idéntico a Safari en iOS 18 para compatibilidad total con apple.com y servicios web
    public static let safariUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1"

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

        // MARK: - 1. SOLUCIÓN DEFINITIVA AL ENCUADRE EN APPLE.COM Y WEBS CON CABECERAS FIJAS
        // .automatic permite que WebKit calcule los insets de la barra de estado y Dynamic Island correctamente
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.customUserAgent = Self.safariUserAgent

        // Margen inferior para que la barra flotante estilo píldora nunca tape el contenido del pie de página
        let bottomBarInset: CGFloat = 84.0
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarInset, right: 0)
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarInset, right: 0)

        // MARK: - 2. SOLUCIÓN DEFINITIVA AL BLOQUEO TÁCTIL (TECLADOS, FORMULARIOS Y ENLACES)
        // Navegación nativa de Safari mediante deslizamiento lateral sin capas transparentes encima
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.keyboardDismissMode = .onDrag
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
