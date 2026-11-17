import Foundation
import WebKit
import Observation
import UIKit

@Observable
public final class WebEngineCoordinator: NSObject, @unchecked Sendable {
    public static let shared = WebEngineCoordinator()

    public var activeTabID: UUID?
    public var tabs: [TabModel] = []
    public var spaces: [SpaceModel] = [SpaceModel.defaultSpace, SpaceModel.privateSpace]
    public var activeSpaceID: UUID = SpaceModel.defaultSpaceID

    public var currentProgress: Double = 0.0
    public var currentIsLoading: Bool = false
    public var currentCanGoBack: Bool = false
    public var currentCanGoForward: Bool = false
    public var currentIsSecure: Bool = false
    public var currentBlockedCount: Int = 0
    public var currentURLString: String = ""
    public var currentDisplayTitle: String = ""

    private var activeWebViewObserver: NSKeyValueObservation?
    private var progressObserver: NSKeyValueObservation?
    private var titleObserver: NSKeyValueObservation?
    private var urlObserver: NSKeyValueObservation?

    public override init() {
        super.init()
        loadPersistedState()
    }

    private func loadPersistedState() {
        if let storedSpaces = StorageEngine.shared.load([SpaceModel].self, from: "spaces.json"), !storedSpaces.isEmpty {
            self.spaces = storedSpaces
        }
        if let storedTabs = StorageEngine.shared.load([TabModel].self, from: "tabs.json"), !storedTabs.isEmpty {
            self.tabs = storedTabs
            self.activeTabID = storedTabs.first?.id
        } else {
            let initialTab = TabModel(url: URL(string: "https://www.google.com"), title: "Google", spaceID: SpaceModel.defaultSpaceID)
            self.tabs = [initialTab]
            self.activeTabID = initialTab.id
            saveTabs()
        }
    }

    public func saveTabs() {
        StorageEngine.shared.save(tabs, to: "tabs.json")
    }

    public func saveSpaces() {
        StorageEngine.shared.save(spaces, to: "spaces.json")
    }

    public var activeTab: TabModel? {
        tabs.first { $0.id == activeTabID }
    }

    public var tabsInActiveSpace: [TabModel] {
        tabs.filter { $0.spaceID == activeSpaceID }
    }

    public func selectTab(id: UUID) {
        guard let tab = tabs.first(where: { $0.id == id }) else { return }
        self.activeTabID = id
        self.activeSpaceID = tab.spaceID

        let webView = TabPoolManager.shared.webView(for: tab)
        bindWebViewObservers(webView: webView, for: tab)

        if webView.url == nil, let initialURL = tab.url {
            webView.load(URLRequest(url: initialURL))
        }

        updateSynchronousState(for: tab, webView: webView)
        saveTabs()
    }

    public func createNewTab(url: URL? = nil, in spaceID: UUID? = nil) -> TabModel {
        let targetSpace = spaceID ?? activeSpaceID
        let isPrivate = spaces.first(where: { $0.id == targetSpace })?.isPrivate ?? false

        let newTab = TabModel(
            url: url ?? URL(string: "https://www.google.com"),
            title: url == nil ? "Nueva Pestaña" : "Cargando…",
            isPrivate: isPrivate,
            spaceID: targetSpace
        )

        tabs.append(newTab)
        saveTabs()
        selectTab(id: newTab.id)
        return newTab
    }

    public func closeTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        let closingActive = (activeTabID == id)
        let closedTab = tabs.remove(at: index)

        TabPoolManager.shared.removeWebView(for: id)
        if let snap = closedTab.snapshotFileName {
            StorageEngine.shared.deleteSnapshot(fileName: snap)
        }

        if tabs.isEmpty {
            let fallback = createNewTab()
            selectTab(id: fallback.id)
        } else if closingActive {
            let nextIndex = min(index, tabs.count - 1)
            selectTab(id: tabs[nextIndex].id)
        }
        saveTabs()
    }

    public func navigate(to input: String) {
        guard let activeTab = activeTab else { return }
        let resolvedURL = URLResolver.resolve(input: input)
        let webView = TabPoolManager.shared.webView(for: activeTab)

        webView.load(URLRequest(url: resolvedURL))
        if let index = tabs.firstIndex(where: { $0.id == activeTab.id }) {
            tabs[index].url = resolvedURL
            tabs[index].lastAccessed = Date()
            saveTabs()
        }
    }

    public func reload() {
        guard let activeTab = activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: activeTab)
        webView.reload()
    }

    public func stop() {
        guard let activeTab = activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: activeTab)
        webView.stopLoading()
    }

    public func goBack() {
        guard let activeTab = activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: activeTab)
        if webView.canGoBack {
            webView.goBack()
        }
    }

    public func goForward() {
        guard let activeTab = activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: activeTab)
        if webView.canGoForward {
            webView.goForward()
        }
    }

    public func captureSnapshotForActiveTab() {
        guard let activeTab = activeTab else { return }
        let webView = TabPoolManager.shared.webView(for: activeTab)
        let config = WKSnapshotConfiguration()
        config.rect = webView.bounds

        webView.takeSnapshot(with: config) { [weak self] image, _ in
            guard let self = self, let image = image else { return }
            let fileName = StorageEngine.shared.saveSnapshot(image: image, for: activeTab.id)
            if let index = self.tabs.firstIndex(where: { $0.id == activeTab.id }) {
                self.tabs[index].snapshotFileName = fileName
                self.saveTabs()
            }
        }
    }

    private func bindWebViewObservers(webView: WKWebView, for tab: TabModel) {
        progressObserver?.invalidate()
        titleObserver?.invalidate()
        urlObserver?.invalidate()

        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.currentProgress = wv.estimatedProgress
                self?.currentIsLoading = wv.isLoading
                self?.currentCanGoBack = wv.canGoBack
                self?.currentCanGoForward = wv.canGoForward
            }
        }

        titleObserver = webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let newTitle = wv.title ?? ""
                self.currentDisplayTitle = newTitle
                if let index = self.tabs.firstIndex(where: { $0.id == tab.id }) {
                    self.tabs[index].title = newTitle.isEmpty ? self.tabs[index].displayHost : newTitle
                    self.saveTabs()
                }
            }
        }

        urlObserver = webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let newURL = wv.url {
                    self.currentURLString = newURL.absoluteString
                    self.currentIsSecure = (newURL.scheme?.lowercased() == "https")
                    if let index = self.tabs.firstIndex(where: { $0.id == tab.id }) {
                        self.tabs[index].url = newURL
                        self.saveTabs()
                    }
                }
            }
        }
    }

    private func updateSynchronousState(for tab: TabModel, webView: WKWebView) {
        currentProgress = webView.estimatedProgress
        currentIsLoading = webView.isLoading
        currentCanGoBack = webView.canGoBack
        currentCanGoForward = webView.canGoForward
        currentURLString = webView.url?.absoluteString ?? tab.url?.absoluteString ?? ""
        currentDisplayTitle = webView.title ?? tab.displayTitle
        currentIsSecure = tab.isSecure
    }

    public func burnSession() {
        TabPoolManager.shared.clearAll()
        StorageEngine.shared.cleanAllSnapshots()

        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: Date.distantPast) {}

        tabs = []
        let initialTab = TabModel(url: URL(string: "https://www.google.com"), title: "Google", spaceID: SpaceModel.defaultSpaceID)
        tabs = [initialTab]
        activeTabID = initialTab.id
        saveTabs()
        selectTab(id: initialTab.id)
    }

    public func extractReaderArticle(completion: @escaping @Sendable (ReaderArticle?) -> Void) {
        guard let tab = activeTab else {
            completion(nil)
            return
        }
        let webView = TabPoolManager.shared.webView(for: tab)
        ReaderModeParser.parse(webView: webView) { article in
            completion(article)
        }
    }
}

public struct URLResolver {
    public static func resolve(input: String) -> URL {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            if let valid = URL(string: trimmed) { return valid }
        }
        if !trimmed.contains(" ") && trimmed.contains(".") && !trimmed.hasSuffix(".") {
            if let valid = URL(string: "https://\(trimmed)") { return valid }
        }

        let engineRaw = UserDefaults.standard.string(forKey: "searchEngine") ?? "Google"
        let baseSearch: String
        switch engineRaw {
        case "DuckDuckGo": baseSearch = "https://duckduckgo.com/?q="
        case "Brave":      baseSearch = "https://search.brave.com/search?q="
        case "Ecosia":     baseSearch = "https://www.ecosia.org/search?q="
        default:           baseSearch = "https://www.google.com/search?q="
        }

        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        return URL(string: "\(baseSearch)\(encoded)") ?? URL(string: "https://www.google.com")!
    }
}
