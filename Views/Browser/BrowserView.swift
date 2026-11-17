import SwiftUI

struct BrowserView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = BrowserViewModel()

    @AppStorage("userName") private var userName = ""
    @State private var isBarVisible = true
    @State private var showScrollTop = false
    @State private var showQRSheet = false
    @State private var qrImage: UIImage?
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            if let activeID = viewModel.tabManager.activeTabID {
                WebContainerView(
                    tabID: .constant(activeID),
                    viewModel: viewModel,
                    onScrollDown: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isBarVisible = false
                            showScrollTop = true
                        }
                    },
                    onScrollUp: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isBarVisible = true
                        }
                    }
                )
                .ignoresSafeArea()
            } else {
                NewTabView(viewModel: viewModel, userName: userName)
            }

            if showScrollTop && !isBarVisible {
                VStack {
                    Spacer()
                    scrollTopButton
                        .padding(.bottom, 94)
                }
                .transition(.scale.combined(with: .opacity))
            }

            VStack {
                Spacer()
                if isBarVisible {
                    FloatingBarView(viewModel: viewModel, onShowTabs: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            viewModel.isShowingTabs = true
                        }
                    })
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isBarVisible)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $viewModel.isShowingTabs) {
            TabGridView(viewModel: viewModel) {
                withAnimation(.spring(response: 0.4)) { viewModel.isShowingTabs = false }
            }
        }
        .sheet(isPresented: $viewModel.isShowingTools) {
            ToolsMenuView(viewModel: viewModel, onQR: generateQR, onShare: shareCurrentURL)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingHistory) {
            HistoryView(manager: viewModel.historyManager) { item in
                viewModel.navigate(to: item.url.absoluteString)
                viewModel.isShowingHistory = false
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.isShowingDownloads) {
            DownloadsView(manager: viewModel.downloadManager)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.isShowingReader) {
            ReaderView(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.isShowingBookmarks) {
            BookmarksView(manager: viewModel.bookmarkManager) { bm in
                viewModel.navigate(to: bm.url.absoluteString)
                viewModel.isShowingBookmarks = false
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showQRSheet) {
            QRSheet(image: qrImage, url: viewModel.tabManager.activeTab?.url?.absoluteString ?? "")
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    @ViewBuilder
    private var scrollTopButton: some View {
        Button {
            withAnimation {
                scrollToTop()
                showScrollTop = false
                isBarVisible = true
            }
        } label: {
            NavIconView(icon: .back, size: 16, color: .white, lineWidth: 2.2)
                .rotationEffect(.degrees(90))
                .frame(width: 42, height: 42)
                .liquidGlass(cornerRadius: 21, intensity: 0.95, specular: 1.2)
        }
        .buttonStyle(.plain)
    }

    private func scrollToTop() {
        guard let id = viewModel.tabManager.activeTabID else { return }
        let wv = viewModel.webView(for: id)
        wv.scrollView.setContentOffset(.zero, animated: true)
    }

    private func generateQR() {
        guard let url = viewModel.tabManager.activeTab?.url?.absoluteString else { return }
        qrImage = viewModel.generateQR(for: url)
        showQRSheet = true
        viewModel.isShowingTools = false
    }

    private func shareCurrentURL() {
        guard let tab = viewModel.tabManager.activeTab,
              let url = tab.url else { return }
        let clean = viewModel.cleanURL(url)
        shareItems = [clean.absoluteString]
        showShareSheet = true
        viewModel.isShowingTools = false
    }
}

struct ToolsMenuView: View {
    @Bindable var viewModel: BrowserViewModel
    var onQR: () -> Void
    var onShare: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var tab: BrowserTab? { viewModel.tabManager.activeTab }

    var body: some View {
        NavigationView {
            List {
                Section("Navegación y lectura") {
                    toolRow(icon: .reader, label: "Modo Lector") {
                        viewModel.isShowingReader = true
                        dismiss()
                    }
                    toolRow(icon: .reader, label: "Buscar en la página") {
                        viewModel.isShowingPageSearch.toggle()
                        dismiss()
                    }
                }

                Section("Compartir") {
                    toolRow(icon: .share, label: "Compartir enlace limpio", action: onShare)
                    toolRow(icon: .qr, label: "Código QR", action: onQR)
                    toolRow(
                        icon: .bookmark(viewModel.bookmarkManager.isBookmarked(url: tab?.url ?? URL(string: "about:blank")!)),
                        label: viewModel.bookmarkManager.isBookmarked(url: tab?.url ?? URL(string: "about:blank")!) ? "Eliminar de marcadores" : "Añadir a marcadores"
                    ) {
                        if let tab {
                            viewModel.bookmarkManager.toggle(title: tab.displayTitle, url: tab.url ?? URL(string: "about:blank")!)
                        }
                        dismiss()
                    }
                }

                Section("Visualización") {
                    toolRow(icon: .settings, label: "Alternar versión de escritorio") {
                        viewModel.toggleDesktopMode()
                        dismiss()
                    }
                    toolRow(icon: .settings, label: "Forzar modo oscuro") {
                        viewModel.toggleForcedDarkMode()
                        dismiss()
                    }
                }

                Section("Privacidad") {
                    toolRow(icon: .private, label: "Quemar sesión activa", isDestructive: true) {
                        viewModel.burnSession()
                        dismiss()
                    }
                    toolRow(icon: .history, label: "Historial de navegación") {
                        viewModel.isShowingHistory = true
                        dismiss()
                    }
                    toolRow(icon: .download, label: "Descargas") {
                        viewModel.isShowingDownloads = true
                        dismiss()
                    }
                }

                Section("Preferencias") {
                    toolRow(icon: .bookmark(false), label: "Marcadores guardados") {
                        viewModel.isShowingBookmarks = true
                        dismiss()
                    }
                    toolRow(icon: .settings, label: "Ajustes del navegador") {
                        viewModel.isShowingSettings = true
                        dismiss()
                    }
                }
            }
            .navigationTitle("Herramientas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func toolRow(icon: BrowserIconView.Icon, label: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                BrowserIconView(icon: icon, size: 20, color: isDestructive ? AppColors.danger : .primary)
                Text(label)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(isDestructive ? AppColors.danger : .primary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func toolRow(icon: ToolIconView.Icon, label: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ToolIconView(icon: icon, size: 20, color: isDestructive ? AppColors.danger : .primary)
                Text(label)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(isDestructive ? AppColors.danger : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct NewTabView: View {
    @Bindable var viewModel: BrowserViewModel
    var userName: String

    private let quickSites: [(String, String, String)] = [
        ("Google", "https://google.com", "🔍"),
        ("YouTube", "https://youtube.com", "▶️"),
        ("Wikipedia", "https://wikipedia.org", "📖"),
        ("GitHub", "https://github.com", "💻"),
        ("Reddit", "https://reddit.com", "💬"),
        ("Hacker News", "https://news.ycombinator.com", "⚡")
    ]

    var body: some View {
        ZStack {
            DarkGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 50)

                    VStack(spacing: 8) {
                        Text(salutation)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(clockTime)
                            .font(.system(size: 54, weight: .light, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.65)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Acceso directo")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.60))
                            .padding(.horizontal, 24)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 85))], spacing: 14) {
                            ForEach(quickSites, id: \.0) { site in
                                Button {
                                    viewModel.navigate(to: site.1)
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(site.2).font(.system(size: 26))
                                        Text(site.0)
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.85))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .liquidGlass(cornerRadius: 18, intensity: 0.85, specular: 1.0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if !viewModel.bookmarkManager.bookmarks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Marcadores")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.60))
                                .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.bookmarkManager.bookmarks.prefix(8)) { bm in
                                        Button {
                                            viewModel.navigate(to: bm.url.absoluteString)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(bm.title)
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .lineLimit(1)
                                                Text(bm.url.host ?? "")
                                                    .font(.system(size: 10, design: .rounded))
                                                    .foregroundStyle(.white.opacity(0.55))
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .liquidGlass(cornerRadius: 16, intensity: 0.8, specular: 1.0)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
    }

    private var salutation: String {
        let name = userName.isEmpty ? "" : ", \(userName)"
        let h = Calendar.current.component(.hour, from: Date())
        if h >= 6 && h < 13 { return "Buenos días\(name)" }
        if h >= 13 && h < 21 { return "Buenas tardes\(name)" }
        return "Buenas noches\(name)"
    }

    private var clockTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

struct QRSheet: View {
    let image: UIImage?
    let url: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Código QR")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            if let img = image {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            Text(url)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button("Cerrar") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
