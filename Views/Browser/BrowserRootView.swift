import SwiftUI
import WebKit

// MARK: - BrowserRootView (Master Navigation Container)

public struct BrowserRootView: View {
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var coordinator = WebEngineCoordinator.shared
    @State private var storage = StorageEngine.shared

    // Hojas y Navegación
    @State private var isShowingSpacesCarousel: Bool = false
    @State private var isShowingToolsSheet: Bool = false
    @State private var isShowingProfileSwitcher: Bool = false
    @State private var isShowingSSLInspector: Bool = false
    @State private var isShowingFindInPage: Bool = false

    // Hojas de Herramientas
    @State private var isShowingHistory: Bool = false
    @State private var isShowingBookmarks: Bool = false
    @State private var isShowingDownloads: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isShowingQR: Bool = false
    @State private var isShowingPasswordVault: Bool = false
    @State private var isShowingAntiSpyDashboard: Bool = false
    @State private var isShowingCredits: Bool = false
    @State private var readerArticle: ReaderArticle? = nil
    @State private var shareSheetItem: Any? = nil

    // Búsqueda en Página
    @State private var findSearchText: String = ""
    @State private var findCurrentMatch: Int = 0
    @State private var findTotalMatches: Int = 0

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let activeTab = storage.activeTab

        ZStack(alignment: .bottom) {
            // Fondo
            theme.background(for: scheme)
                .ignoresSafeArea()

            // 1. Contenedor Web Directo o Pantalla de Inicio
            VStack(spacing: 0) {
                if let tab = activeTab, !tab.isNewTab {
                    // CONTENEDOR 100% LIBRE DE OVERLAYS - TOQUES DIRECTOS AL WKWEBVIEW
                    activeWebContainer(for: tab)
                        .ignoresSafeArea(.container, edges: .top)
                } else {
                    SmartHomeDashboardView(
                        onSelectQuery: { query in
                            coordinator.navigate(to: query)
                        },
                        onSelectURL: { url in
                            coordinator.loadURL(url)
                        },
                        onOpenProfileSwitcher: {
                            isShowingProfileSwitcher = true
                        }
                    )
                }

                // Espacio reservado para la barra inferior fija
                Spacer(minLength: 0)
            }

            // 2. Barra Inferior Fija de Apple Safari (Full-width Search + Controls)
            VStack(spacing: 6) {
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

                AppleSafariBottomBar(
                    coordinator: coordinator,
                    onOpenSSLInspector: {
                        coordinator.triggerSSLInspection()
                        isShowingSSLInspector = true
                    },
                    onOpenTools: {
                        isShowingToolsSheet = true
                    },
                    onOpenSpaces: {
                        isShowingSpacesCarousel = true
                    },
                    onNewTab: {
                        _ = coordinator.createNewTab()
                    }
                )
            }
        }
        // --- SHEETS Y MODALES NATIVAS ---
        .sheet(isPresented: $isShowingSSLInspector) {
            if let sslInfo = coordinator.currentSSLInfo {
                SecurityInspectorSheet(info: sslInfo) { domain in
                    coordinator.reload()
                }
            } else {
                SecurityInspectorSheet(info: SSLCertificateInfo.placeholder(domain: activeTab?.displayHost ?? "Web"))
            }
        }
        .sheet(isPresented: $isShowingSpacesCarousel) {
            SpacesCarouselView(coordinator: coordinator)
        }
        .sheet(isPresented: $isShowingProfileSwitcher) {
            ProfileSwitcherSheet()
        }
        .sheet(isPresented: $isShowingToolsSheet) {
            toolsMenuCompactSheet(theme: theme, scheme: scheme)
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
    }

    // MARK: - Contenedor Web Directo (Cero Bloqueo Táctil)

    @ViewBuilder
    private func activeWebContainer(for tab: TabModel) -> some View {
        let webView = TabPoolManager.shared.webView(for: tab)
        WebViewWrapper(webView: webView)
    }

    // MARK: - Menú de Herramientas Compacto

    @ViewBuilder
    private func toolsMenuCompactSheet(theme: ThemeManager, scheme: ColorScheme) -> some View {
        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                List {
                    // Sección 1: Lectura y Utilidades de Página
                    Section {
                        Button {
                            isShowingToolsSheet = false
                            coordinator.extractReaderArticle { article in
                                DispatchQueue.main.async {
                                    self.readerArticle = article
                                }
                            }
                        } label: {
                            toolsRow(icon: .readerMode, title: "Modo Lectura", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            withAnimation(LiquidAnimation.interactiveSpring) {
                                isShowingFindInPage = true
                            }
                        } label: {
                            toolsRow(icon: .search, title: "Buscar en la página", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            coordinator.toggleDarkMode()
                        } label: {
                            toolsRow(icon: .palette, title: coordinator.isDarkModeInjected ? "Desactivar Modo Oscuro Forzado" : "Activar Modo Oscuro Forzado", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            isShowingQR = true
                        } label: {
                            toolsRow(icon: .qrCode, title: "Generar Código QR", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            exportPDF()
                        } label: {
                            toolsRow(icon: .pdfExport, title: "Exportar como PDF", theme: theme, scheme: scheme)
                        }
                    }

                    // Sección 2: Navegación y Datos
                    Section {
                        Button {
                            isShowingToolsSheet = false
                            isShowingHistory = true
                        } label: {
                            toolsRow(icon: .history, title: "Historial de Navegación", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            isShowingBookmarks = true
                        } label: {
                            toolsRow(icon: .bookmarks, title: "Marcadores", theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            isShowingDownloads = true
                        } label: {
                            toolsRow(icon: .downloads, title: "Descargas", theme: theme, scheme: scheme)
                        }
                    }

                    // Sección 3: Compartir y Ajustes
                    Section {
                        Button {
                            isShowingToolsSheet = false
                            if let url = URL(string: coordinator.currentURLString) {
                                self.shareSheetItem = url
                            }
                        } label: {
                            toolsRow(icon: .share, title: Loc.tr("bar_share"), theme: theme, scheme: scheme)
                        }

                        Button {
                            isShowingToolsSheet = false
                            isShowingSettings = true
                        } label: {
                            toolsRow(icon: .settings, title: Loc.tr("settings_title"), theme: theme, scheme: scheme)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Loc.tr("bar_tools"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) { isShowingToolsSheet = false }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    @ViewBuilder
    private func toolsRow(icon: LiquidIconType, title: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        HStack(spacing: 14) {
            LiquidIconView(icon, size: 18, color: theme.textPrimary(for: scheme))
            Text(title)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))
            Spacer()
        }
    }

    private func exportPDF() {
        guard let tab = storage.activeTab else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        FullPagePDFExporter.export(webView: wv) { url in
            DispatchQueue.main.async {
                if let fileURL = url {
                    self.shareSheetItem = fileURL
                }
            }
        }
    }

    private func searchNextInPage() {
        guard let tab = storage.activeTab else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        let js = "window.find('\(findSearchText)', false, false, true, false, false, false);"
        wv.evaluateJavaScript(js)
    }

    private func searchPrevInPage() {
        guard let tab = storage.activeTab else { return }
        let wv = TabPoolManager.shared.webView(for: tab)
        let js = "window.find('\(findSearchText)', false, true, true, false, false, false);"
        wv.evaluateJavaScript(js)
    }
}

// MARK: - WebViewWrapper (Direct UIViewRepresentable for WKWebView)

public struct WebViewWrapper: UIViewRepresentable {
    public let webView: WKWebView

    public init(webView: WKWebView) {
        self.webView = webView
    }

    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - ReaderArticleWrapper & IdentifiableActivityItem

public struct ReaderArticleWrapper: Identifiable {
    public let id = UUID()
    public let article: ReaderArticle

    public init(article: ReaderArticle) {
        self.article = article
    }
}

public struct IdentifiableActivityItem: Identifiable {
    public let id = UUID()
    public let item: Any

    public init(item: Any) {
        self.item = item
    }
}

// MARK: - ActivityShareSheet

public struct ActivityShareSheet: UIViewControllerRepresentable {
    public let activityItems: [Any]

    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
