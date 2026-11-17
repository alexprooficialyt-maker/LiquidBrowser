import SwiftUI
import WebKit
import LocalAuthentication

// MARK: - BrowserViewModel

@Observable
final class BrowserViewModel: NSObject {

    // Sub-managers
    var tabManager:      TabManager      = TabManager()
    var bookmarkManager: BookmarkManager = BookmarkManager()
    var historyManager:  HistoryManager  = HistoryManager()
    var downloadManager: DownloadManager = DownloadManager()

    // UI State
    var urlBarText:        String  = ""
    var isEditingURL:      Bool    = false
    var isShowingTabs:     Bool    = false
    var isShowingTools:    Bool    = false
    var isShowingHistory:  Bool    = false
    var isShowingBookmarks:Bool    = false
    var isShowingDownloads:Bool    = false
    var isShowingSettings: Bool    = false
    var isShowingReader:   Bool    = false
    var isBarVisible:      Bool    = true
    var isPrivateMode:     Bool    = false
    var isPrivateLocked:   Bool    = false
    var tabSearchQuery:    String  = ""
    var blockedTrackers:   Int     = 0

    // Texto buscado en página
    var pageSearchText:    String  = ""
    var pageSearchCount:   Int     = 0
    var isShowingPageSearch: Bool  = false

    // Zoom por dominio
    private var domainZoom: [String: Double] = [:]

    @AppStorage("searchEngine") private var searchEngineRaw = "Google"
    @AppStorage("autoCloseTabsDays") private var autoCloseDays = 0

    private var webViews: [UUID: WKWebView] = [:]
    private var contentController: WKUserContentController?

    // MARK: - Init

    override init() {
        super.init()
        setupContentRules()
        _ = tabManager.newTab()
        applyAutoClose()
    }

    // MARK: - WebView por pestaña

    func webView(for tabID: UUID, isPrivate: Bool = false) -> WKWebView {
        if let existing = webViews[tabID] { return existing }
        let config = WKWebViewConfiguration()
        if isPrivate {
            config.websiteDataStore = .nonPersistent()
        }
        config.userContentController = contentController ?? WKUserContentController()
        config.allowsInlineMediaPlayback = true

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        wv.navigationDelegate = self
        wv.uiDelegate         = self
        wv.scrollView.contentInsetAdjustmentBehavior = .always
        webViews[tabID] = wv
        return wv
    }

    // MARK: - Navegación

    func navigate(to input: String, tabID: UUID? = nil) {
        let id  = tabID ?? tabManager.activeTabID
        guard let id else { return }
        let url = resolveURL(from: input)
        let wv  = webView(for: id)
        wv.load(URLRequest(url: url))
        isEditingURL = false
        urlBarText   = input
        tabManager.update(tabID: id, url: url)
    }

    func goBack() {
        guard let id = tabManager.activeTabID else { return }
        webView(for: id).goBack()
    }

    func goForward() {
        guard let id = tabManager.activeTabID else { return }
        webView(for: id).goForward()
    }

    func reload() {
        guard let id = tabManager.activeTabID else { return }
        webView(for: id).reload()
    }

    func stopLoading() {
        guard let id = tabManager.activeTabID else { return }
        webView(for: id).stopLoading()
    }

    var canGoBack: Bool {
        guard let id = tabManager.activeTabID else { return false }
        return webViews[id]?.canGoBack ?? false
    }

    var canGoForward: Bool {
        guard let id = tabManager.activeTabID else { return false }
        return webViews[id]?.canGoForward ?? false
    }

    // MARK: - Cambiar pestaña activa

    func selectTab(_ id: UUID) {
        tabManager.activeTabID = id
        if let tab = tabManager.activeTab {
            urlBarText = tab.url?.absoluteString ?? ""
        }
        // Si la webview no tiene url cargada pero la pestaña sí, navegar
        if let tab = tabManager.activeTab, let url = tab.url {
            let wv = webView(for: id, isPrivate: tab.isPrivate)
            if wv.url == nil { wv.load(URLRequest(url: url)) }
        }
    }

    // MARK: - Zoom por dominio

    func setZoom(_ zoom: Double) {
        guard let host = tabManager.activeTab?.url?.host else { return }
        domainZoom[host] = zoom
        guard let id = tabManager.activeTabID else { return }
        let script = "document.body.style.zoom = '\(Int(zoom))%'"
        webViews[id]?.evaluateJavaScript(script)
    }

    func zoomForCurrentDomain() -> Double {
        guard let host = tabManager.activeTab?.url?.host else { return 100 }
        return domainZoom[host] ?? 100
    }

    // MARK: - Modo escritorio / móvil

    func toggleDesktopMode() {
        guard let id = tabManager.activeTabID else { return }
        let wv = webViews[id]
        if wv?.customUserAgent == nil || wv?.customUserAgent?.isEmpty == true {
            wv?.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
        } else {
            wv?.customUserAgent = nil
        }
        wv?.reload()
    }

    // MARK: - Modo oscuro forzado en web

    func toggleForcedDarkMode() {
        guard let id = tabManager.activeTabID else { return }
        let css = """
        html { filter: invert(1) hue-rotate(180deg) !important; }
        img, video { filter: invert(1) hue-rotate(180deg) !important; }
        """
        let script = """
        var style = document.getElementById('_lbDarkMode');
        if (style) { style.remove(); } else {
            var s = document.createElement('style');
            s.id = '_lbDarkMode';
            s.textContent = `\(css)`;
            document.head.appendChild(s);
        }
        """
        webViews[id]?.evaluateJavaScript(script)
    }

    // MARK: - Búsqueda en página

    func searchInPage(_ text: String) {
        guard let id = tabManager.activeTabID else { return }
        let script = """
        window.getSelection().removeAllRanges();
        var count = 0;
        if ('\(text)'.length > 0) {
            var body = document.body.innerHTML;
            var regex = new RegExp('\(text)', 'gi');
            count = (body.match(regex) || []).length;
            window.find('\(text)', false, false, true);
        }
        count;
        """
        webViews[id]?.evaluateJavaScript(script) { [weak self] result, _ in
            self?.pageSearchCount = (result as? Int) ?? 0
        }
    }

    func nextPageResult() {
        guard let id = tabManager.activeTabID, !pageSearchText.isEmpty else { return }
        webViews[id]?.evaluateJavaScript("window.find('\(pageSearchText)', false, false, true)")
    }

    func prevPageResult() {
        guard let id = tabManager.activeTabID, !pageSearchText.isEmpty else { return }
        webViews[id]?.evaluateJavaScript("window.find('\(pageSearchText)', false, true, true)")
    }

    // MARK: - Captura de página completa

    func captureFullPage(completion: @escaping (UIImage?) -> Void) {
        guard let id = tabManager.activeTabID,
              let wv = webViews[id] else { completion(nil); return }
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(origin: .zero, size: wv.scrollView.contentSize)
        wv.takeSnapshot(with: config) { image, _ in
            DispatchQueue.main.async { completion(image) }
        }
    }

    // MARK: - Generar QR de URL actual

    func generateQR(for string: String) -> UIImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H",  forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        return UIImage(ciImage: scaled)
    }

    // MARK: - Limpiar URL de rastreadores

    func cleanURL(_ url: URL) -> URL {
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
        let trackerParams = ["utm_source","utm_medium","utm_campaign","utm_term","utm_content",
                             "fbclid","gclid","msclkid","ref","source","mc_cid","mc_eid"]
        comps.queryItems = comps.queryItems?.filter { item in
            !trackerParams.contains(item.name.lowercased())
        }
        if comps.queryItems?.isEmpty == true { comps.queryItems = nil }
        return comps.url ?? url
    }

    // MARK: - Quemar sesión

    func burnSession() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast) {}
        historyManager.clearAll()
        tabManager.tabs.removeAll { !$0.isPinned }
        _ = tabManager.newTab()
        blockedTrackers = 0
    }

    // MARK: - Bloqueo biométrico pestañas privadas

    func unlockPrivateTabs(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(true); return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: "Acceder a pestañas privadas") { success, _ in
            DispatchQueue.main.async { completion(success) }
        }
    }

    // MARK: - Modo lectura (extracción básica)

    func extractReaderContent(completion: @escaping (String) -> Void) {
        guard let id = tabManager.activeTabID else { completion(""); return }
        let script = """
        var article = document.querySelector('article') ||
                      document.querySelector('main') ||
                      document.querySelector('.post-content') ||
                      document.body;
        article ? article.innerText : document.body.innerText;
        """
        webViews[id]?.evaluateJavaScript(script) { result, _ in
            DispatchQueue.main.async {
                completion((result as? String) ?? "")
            }
        }
    }

    // MARK: - Privado: resolver URL / búsqueda

    private func resolveURL(from input: String) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Es URL directa
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return URL(string: trimmed) ?? searchURL(for: trimmed)
        }
        // Parece dominio (contiene punto, sin espacios)
        if !trimmed.contains(" ") && trimmed.contains(".") {
            return URL(string: "https://\(trimmed)") ?? searchURL(for: trimmed)
        }
        return searchURL(for: trimmed)
    }

    private func searchURL(for query: String) -> URL {
        let engine: AppState.SearchEngine = AppState.SearchEngine(rawValue: searchEngineRaw) ?? .google
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: engine.searchURL + encoded)!
    }

    // MARK: - Bloqueador de rastreadores

    private func setupContentRules() {
        let rules = """
        [
          {"trigger":{"url-filter":".*doubleclick\\\\.net.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*googlesyndication\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*googletagmanager\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*facebook\\\\.com/tr.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*analytics\\\\.google\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*hotjar\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*ads\\\\.twitter\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*amazon-adsystem\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*outbrain\\\\.com.*"},"action":{"type":"block"}},
          {"trigger":{"url-filter":".*taboola\\\\.com.*"},"action":{"type":"block"}}
        ]
        """
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "LiquidBrowserBlocker",
            encodedContentRuleList: rules
        ) { [weak self] list, error in
            guard let list else { return }
            let controller = WKUserContentController()
            controller.add(list)
            self?.contentController = controller
        }
    }

    private func applyAutoClose() {
        tabManager.autoCloseInactiveTabs(olderThanDays: autoCloseDays)
    }
}

// MARK: - WKNavigationDelegate

extension BrowserViewModel: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let id = webViewID(webView) else { return }
        tabManager.update(tabID: id, isLoading: true, progress: 0.1)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let id = webViewID(webView) else { return }
        if let url = webView.url {
            let clean = cleanURL(url)
            tabManager.update(tabID: id, url: clean)
            if tabManager.activeTabID == id {
                urlBarText = clean.absoluteString
            }
        }
        blockedTrackers += 1 // contador simbólico (incrementa por carga)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let id = webViewID(webView) else { return }
        tabManager.update(tabID: id, title: webView.title ?? "", isLoading: false, progress: 1.0)
        if let url = webView.url {
            historyManager.record(url: url, title: webView.title ?? url.absoluteString)
        }
        // Captura snapshot para cuadrícula de pestañas
        let config = WKSnapshotConfiguration()
        webView.takeSnapshot(with: config) { [weak self] image, _ in
            if let image { self?.tabManager.update(tabID: id, snapshot: image) }
        }
        // Aplicar zoom guardado
        if let host = webView.url?.host, let zoom = domainZoom[host] {
            webView.evaluateJavaScript("document.body.style.zoom = '\(Int(zoom))%'")
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard let id = webViewID(webView) else { return }
        tabManager.update(tabID: id, isLoading: false)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Interceptar descargas
        if let url = navigationAction.request.url,
           ["pdf","zip","mp3","mp4","docx","xlsx"].contains(url.pathExtension.lowercased()) {
            downloadManager.start(url: url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func webViewID(_ webView: WKWebView) -> UUID? {
        webViews.first(where: { $0.value === webView })?.key
    }
}

// MARK: - WKUIDelegate

extension BrowserViewModel: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Abrir ventanas nuevas como pestañas
        if let url = navigationAction.request.url {
            let id = tabManager.newTab(url: url)
            selectTab(id)
        }
        return nil
    }
}
