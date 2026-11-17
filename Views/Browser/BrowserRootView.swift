import SwiftUI
import WebKit

// MARK: - BrowserRootView (Contenedor Maestro de Navegación)

public struct BrowserRootView: View {
    @State private var coordinator = WebEngineCoordinator.shared

    @State private var isShowingTabsGrid: Bool = false
    @State private var isShowingToolsMenu: Bool = false
    @State private var isShowingFindInPage: Bool = false

    // Modales y Hojas
    @State private var isShowingHistory: Bool = false
    @State private var isShowingBookmarks: Bool = false
    @State private var isShowingDownloads: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isShowingQR: Bool = false
    @State private var readerArticle: ReaderArticle? = nil
    @State private var shareSheetItem: Any? = nil

    @State private var findSearchText: String = ""
    @State private var findCurrentMatch: Int = 0
    @State private var findTotalMatches: Int = 0

    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared

        ZStack(alignment: .bottom) {
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            // Contenedor Web o Pantalla de Inicio NewTabHomeView
            if let activeTab = coordinator.activeTab {
                if let url = activeTab.url, url.absoluteString != "about:blank" && !url.absoluteString.isEmpty {
                    activeWebContainer(for: activeTab)
                        .ignoresSafeArea(.container, edges: .top)
                } else {
                    NewTabHomeView(coordinator: coordinator)
                }
            } else {
                NewTabHomeView(coordinator: coordinator)
            }

            // Barra Flotante Inferior SIEMPRE FIJA (nunca se oculta al hacer scroll)
            VStack(spacing: 8) {
                if isShowingFindInPage {
                    FindInPageBar(
                        searchText: $findSearchText,
                        currentMatch: $findCurrentMatch,
                        totalMatches: $findTotalMatches,
                        onNext: { searchNextInPage() },
                        onPrevious: { searchPrevInPage() },
                        onClose: {
                            withAnimation(LiquidAnimation.interactiveSpring) {
                                isShowingFindInPage = false
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                FloatingGlassCapsule(
                    coordinator: coordinator,
                    onOpenTabs: {
                        HapticManager.shared.touchLight()
                        coordinator.captureSnapshotForActiveTab()
                        withAnimation(LiquidAnimation.interactiveSpring) {
                            isShowingTabsGrid = true
                        }
                    },
                    onOpenTools: {
                        HapticManager.shared.touchLight()
                        isShowingToolsMenu = true
                    }
                )
            }
            .padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $isShowingTabsGrid) {
            SpacesTabGridView(coordinator: coordinator) {
                withAnimation(LiquidAnimation.interactiveSpring) {
                    isShowingTabsGrid = false
                }
            }
        }
        .sheet(isPresented: $isShowingToolsMenu) {
            toolsMenuCompactSheet
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryView { url in
                isShowingHistory = false
                coordinator.loadURL(url)
            }
        }
        .sheet(isPresented: $isShowingBookmarks) {
            BookmarksView { url in
                isShowingBookmarks = false
                coordinator.loadURL(url)
            }
        }
        .sheet(isPresented: $isShowingDownloads) {
            DownloadsView()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $isShowingQR) {
            QRGeneratorView(urlString: coordinator.currentURLString)
        }
        .sheet(item: Binding<ReaderArticleWrapper?>(
            get: { readerArticle.map { ReaderArticleWrapper(article: $0) } },
            set: { readerArticle = $0?.article }
        )) { wrapper in
            ReaderView(article: wrapper.article)
        }
        .sheet(item: Binding<IdentifiableActivityItem?>(
            get: { shareSheetItem.map { IdentifiableActivityItem(item: $0) } },
            set: { _ in shareSheetItem = nil }
        )) { actItem in
            ActivityShareSheet(activityItems: [actItem.item])
        }
        .onAppear {
            if let active = coordinator.activeTab {
                coordinator.selectTab(id: active.id)
            }
        }
    }

    // MARK: - Active Web Container

    @ViewBuilder
    private func activeWebContainer(for tab: TabModel) -> some View {
        let webView = TabPoolManager.shared.webView(for: tab)

        ZStack {
            WebViewWrapper(webView: webView)

            GestureNavigationOverlay(
                webView: webView,
                onEdgeBack: { coordinator.goBack() },
                onEdgeForward: { coordinator.goForward() }
            )
        }
    }

    // MARK: - Tools Menu Compact Sheet

    @ViewBuilder
    private var toolsMenuCompactSheet: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                List {
                    // SECCIÓN: NAVEGACIÓN Y LECTURA
                    Section {
                        Button(action: {
                            isShowingToolsMenu = false
                            coordinator.extractReaderArticle { article in
                                DispatchQueue.main.async {
                                    self.readerArticle = article
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.readerMode, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Modo Lectura")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            withAnimation(LiquidAnimation.interactiveSpring) {
                                isShowingFindInPage = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.search, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Buscar en la página")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            guard let tab = coordinator.activeTab else { return }
                            let wv = TabPoolManager.shared.webView(for: tab)
                            DarkModeCSSInjector.toggleDarkMode(on: wv, enabled: true)
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.sliderAdjust, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Modo Oscuro Forzado")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                    } header: {
                        Text("Página actual")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: BIBLIOTECA
                    Section {
                        Button(action: {
                            isShowingToolsMenu = false
                            isShowingBookmarks = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.bookmark, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Marcadores")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            isShowingHistory = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.history, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Historial de visitas y búsquedas")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            isShowingDownloads = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.download, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Descargas")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                    } header: {
                        Text("Biblioteca")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: COMPARTIR Y ACCIONES
                    Section {
                        Button(action: {
                            isShowingToolsMenu = false
                            isShowingQR = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.qrCode, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Código QR")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            exportPageToPDF()
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.share, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Exportar a PDF")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }

                        Button(action: {
                            isShowingToolsMenu = false
                            isShowingSettings = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.settings, size: 18, color: theme.textPrimary(for: colorScheme))
                                Text("Ajustes")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                    } header: {
                        Text("Acciones")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Herramientas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        HapticManager.shared.touchLight()
                        isShowingToolsMenu = false
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
            }
        }
    }

    // MARK: - Actions

    private func exportPageToPDF() {
        guard let tab = coordinator.activeTab else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        FullPagePDFExporter.exportPDF(from: wv) { fileURL in
            DispatchQueue.main.async {
                self.shareSheetItem = fileURL
            }
        }
    }

    private func searchNextInPage() {
        guard let tab = coordinator.activeTab, !findSearchText.isEmpty else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        let js = "window.find('\(findSearchText)', false, false, true);"
        wv.evaluateJavaScript(js)
    }

    private func searchPrevInPage() {
        guard let tab = coordinator.activeTab, !findSearchText.isEmpty else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        let js = "window.find('\(findSearchText)', false, true, true);"
        wv.evaluateJavaScript(js)
    }
}

// MARK: - ReaderArticleWrapper

public struct ReaderArticleWrapper: Identifiable {
    public let id = UUID()
    public let article: ReaderArticle
}

// MARK: - IdentifiableActivityItem

public struct IdentifiableActivityItem: Identifiable {
    public let id = UUID()
    public let item: Any
}

// MARK: - WebViewWrapper

public struct WebViewWrapper: UIViewRepresentable {
    public let webView: WKWebView

    public init(webView: WKWebView) {
        self.webView = webView
    }

    public func makeUIView(context: Context) -> WKWebView {
        webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}
