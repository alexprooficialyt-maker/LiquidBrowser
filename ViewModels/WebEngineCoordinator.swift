import Foundation
import WebKit
import Observation
import UIKit

// MARK: - WebEngineCoordinator (@Observable Main WebKit Engine Coordinator)

@Observable
public final class WebEngineCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, @unchecked Sendable {
    public static let shared = WebEngineCoordinator()

    // Progreso y Estado de Carga
    public var currentProgress: Double = 0.0
    public var currentIsLoading: Bool = false
    public var currentCanGoBack: Bool = false
    public var currentCanGoForward: Bool = false
    public var currentIsSecure: Bool = true
    public var currentURLString: String = ""
    public var currentDisplayTitle: String = ""
    public var currentSSLInfo: SSLCertificateInfo? = nil

    // Modo Oscuro Inyectado
    public var isDarkModeInjected: Bool = false

    // Búsqueda en Página
    public var findSearchText: String = ""
    public var findCurrentMatch: Int = 0
    public var findTotalMatches: Int = 0

    // Observadores KVO
    private var progressObserver: NSKeyValueObservation?
    private var titleObserver: NSKeyValueObservation?
    private var urlObserver: NSKeyValueObservation?
    private var canGoBackObserver: NSKeyValueObservation?
    private var canGoForwardObserver: NSKeyValueObservation?
    private var loadingObserver: NSKeyValueObservation?

    public override init() {
        super.init()
        setupActiveTab()
    }

    public func setupActiveTab() {
        if let tab = StorageEngine.shared.activeTab {
            selectTab(id: tab.id)
        }
    }

    // MARK: - Tab Selection & Multi-Instance In-Memory Pool

    public func selectTab(id: UUID) {
        StorageEngine.shared.activeTabID = id
        guard let tab = StorageEngine.shared.activeTab else { return }

        let webView = TabPoolManager.shared.webView(for: tab)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        bindObservers(to: webView, for: tab)

        // Si la pestaña tiene URL y aún no ha cargado nada, cargarla
        if webView.url == nil, let url = tab.url {
            webView.load(URLRequest(url: url))
        }

        updateStateFromWebView(webView, for: tab)
    }

    public func createNewTab(url: URL? = nil, inSpace spaceID: UUID? = nil, isPrivate: Bool = false) -> TabModel {
        let newTab = StorageEngine.shared.createTab(url: url, spaceID: spaceID, isPrivate: isPrivate)
        selectTab(id: newTab.id)

        if let url = url {
            let webView = TabPoolManager.shared.webView(for: newTab)
            webView.load(URLRequest(url: url))
        }

        return newTab
    }

    public func closeTab(id: UUID) {
        TabPoolManager.shared.removeWebView(for: id)
        StorageEngine.shared.closeTab(id: id)

        if let nextTab = StorageEngine.shared.activeTab {
            selectTab(id: nextTab.id)
        }
    }

    // MARK: - Browser Actions (100% Touch & Keyboard Compliant)

    public func navigate(to input: String) {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let resolvedURL = URLResolver.resolve(input: input)
        let webView = TabPoolManager.shared.webView(for: tab)

        webView.load(URLRequest(url: resolvedURL))
        StorageEngine.shared.updateTabURL(id: tab.id, url: resolvedURL, title: nil)

        // Registrar búsqueda o visita
        let isSearch = !input.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("http") && (!input.contains(".") || input.contains(" "))
        if isSearch {
            let engineRaw = UserDefaults.standard.string(forKey: "smartbot_default_search_engine") ?? SearchEngineType.google.rawValue
            let engine = SearchEngineType(rawValue: engineRaw) ?? .google
            StorageEngine.shared.recordSearch(query: input, engine: engine)
        }

        StorageEngine.shared.recordVisit(
            url: resolvedURL,
            title: tab.displayTitle,
            isSearch: isSearch,
            query: isSearch ? input : nil
        )
    }

    public func loadURL(_ url: URL) {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        webView.load(URLRequest(url: url))
        StorageEngine.shared.updateTabURL(id: tab.id, url: url, title: nil)
        StorageEngine.shared.recordVisit(url: url, title: tab.displayTitle)
    }

    public func reload() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        webView.reload()
    }

    public func stop() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        webView.stopLoading()
    }

    public func goBack() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        if webView.canGoBack {
            webView.goBack()
        }
    }

    public func goForward() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        if webView.canGoForward {
            webView.goForward()
        }
    }

    // MARK: - SSL Inspection

    public func triggerSSLInspection() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        let info = SSLInspectorEngine.shared.inspect(url: webView.url ?? tab.url, serverTrust: webView.serverTrust)
        self.currentSSLInfo = info
        self.currentIsSecure = info.isSecure
    }

    // MARK: - Reader Mode & PDF Export

    public func extractReaderArticle(completion: @escaping @Sendable (ReaderArticle?) -> Void) {
        guard let tab = StorageEngine.shared.activeTab else {
            completion(nil)
            return
        }
        let webView = TabPoolManager.shared.webView(for: tab)
        ReaderModeParser.parse(webView: webView) { article in
            completion(article)
        }
    }

    // MARK: - Dark Mode CSS Injection

    public func toggleDarkMode() {
        guard let tab = StorageEngine.shared.activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: tab)
        isDarkModeInjected.toggle()
        DarkModeCSSInjector.shared.apply(to: webView, enabled: isDarkModeInjected)
    }

    // MARK: - KVO Observers

    private func bindObservers(to webView: WKWebView, for tab: TabModel) {
        progressObserver?.invalidate()
        titleObserver?.invalidate()
        urlObserver?.invalidate()
        canGoBackObserver?.invalidate()
        canGoForwardObserver?.invalidate()
        loadingObserver?.invalidate()

        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.currentProgress = wv.estimatedProgress
            }
        }

        loadingObserver = webView.observe(\.isLoading, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.currentIsLoading = wv.isLoading
            }
        }

        canGoBackObserver = webView.observe(\.canGoBack, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.currentCanGoBack = wv.canGoBack
            }
        }

        canGoForwardObserver = webView.observe(\.canGoForward, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.currentCanGoForward = wv.canGoForward
            }
        }

        titleObserver = webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let newTitle = wv.title ?? ""
                self.currentDisplayTitle = newTitle
                StorageEngine.shared.updateTabURL(id: tab.id, url: nil, title: newTitle)
            }
        }

        urlObserver = webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                guard let self = self, let newURL = wv.url else { return }
                self.currentURLString = newURL.absoluteString
                self.currentIsSecure = (newURL.scheme?.lowercased() == "https")
                StorageEngine.shared.updateTabURL(id: tab.id, url: newURL, title: nil)
                self.triggerSSLInspection()
            }
        }
    }

    private func updateStateFromWebView(_ webView: WKWebView, for tab: TabModel) {
        currentProgress = webView.estimatedProgress
        currentIsLoading = webView.isLoading
        currentCanGoBack = webView.canGoBack
        currentCanGoForward = webView.canGoForward
        currentURLString = webView.url?.absoluteString ?? tab.url?.absoluteString ?? ""
        currentDisplayTitle = webView.title ?? tab.displayTitle
        currentIsSecure = (webView.url?.scheme?.lowercased() == "https")
        triggerSSLInspection()
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        currentIsLoading = true
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        currentIsLoading = false
        triggerSSLInspection()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        currentIsLoading = false
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        currentIsLoading = false
    }
}
