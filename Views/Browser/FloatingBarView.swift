import SwiftUI

// MARK: - FloatingBarView
// Cápsula suspendida en la parte inferior con ergonomía a una mano

struct FloatingBarView: View {
    @Bindable var viewModel: BrowserViewModel
    var onShowTabs: () -> Void

    @State private var dragOffsetX: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

    private var activeTab: BrowserTab? { viewModel.tabManager.activeTab }

    var body: some View {
        VStack(spacing: 0) {
            // Buscador en página (aparece encima si está activo)
            if viewModel.isShowingPageSearch {
                pageSearchBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 8)
            }

            // Cápsula principal
            HStack(spacing: 0) {
                // Atrás
                GlassButton(
                    icon: AnyView(NavIconView(icon: .back, size: 20)),
                    size: 44,
                    isActive: false
                ) { viewModel.goBack() }
                .disabled(!viewModel.canGoBack)
                .opacity(viewModel.canGoBack ? 1 : 0.35)

                // Recargar / Stop
                GlassButton(
                    icon: AnyView(
                        Group {
                            if activeTab?.isLoading == true {
                                NavIconView(icon: .stop, size: 18)
                            } else {
                                NavIconView(icon: .reload, size: 20)
                            }
                        }
                    ),
                    size: 40
                ) {
                    if activeTab?.isLoading == true { viewModel.stopLoading() }
                    else { viewModel.reload() }
                }

                // URL Bar central — deslizable para cambiar de pestaña
                URLBarView(
                    text: $viewModel.urlBarText,
                    isEditing:    viewModel.isEditingURL,
                    isLoading:    activeTab?.isLoading ?? false,
                    isSecure:     activeTab?.isSecure ?? false,
                    progress:     activeTab?.loadProgress ?? 0,
                    blockedCount: viewModel.blockedTrackers,
                    onCommit: { input in
                        viewModel.navigate(to: input)
                        viewModel.isEditingURL = false
                    },
                    onTap: {
                        withAnimation(.spring(response: 0.3)) { viewModel.isEditingURL = true }
                    },
                    onCancel: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.isEditingURL = false
                            viewModel.urlBarText = activeTab?.url?.absoluteString ?? ""
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in dragOffsetX = value.translation.width }
                        .onEnded   { value in handleTabSwipe(value.translation.width) }
                )

                // Adelante
                GlassButton(
                    icon: AnyView(NavIconView(icon: .forward, size: 20)),
                    size: 44
                ) { viewModel.goForward() }
                .disabled(!viewModel.canGoForward)
                .opacity(viewModel.canGoForward ? 1 : 0.35)

                // Compartir / Herramientas
                GlassButton(
                    icon: AnyView(ToolIconView(icon: .share, size: 20)),
                    size: 44
                ) { viewModel.isShowingTools = true }

                // Pestañas con contador
                tabsButton
            }
            .padding(.horizontal, 6)
            .liquidCapsule()
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Botón pestañas

    @ViewBuilder
    private var tabsButton: some View {
        Button(action: onShowTabs) {
            ZStack {
                BrowserIconView(
                    icon: .tabs(viewModel.tabManager.tabs.count),
                    size: 22, color: .primary, lineWidth: 2.0
                )
                // Contador numérico encima
                Text("\(viewModel.tabManager.tabs.count)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .offset(x: 4, y: -4)
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Barra de búsqueda en página

    @ViewBuilder
    private var pageSearchBar: some View {
        HStack(spacing: 10) {
            TextField("Buscar en la página…", text: $viewModel.pageSearchText)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.primary)
                .tint(.blue)
                .onChange(of: viewModel.pageSearchText) { _, new in
                    viewModel.searchInPage(new)
                }

            if viewModel.pageSearchCount > 0 {
                Text("\(viewModel.pageSearchCount)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Button(action: viewModel.prevPageResult) {
                NavIconView(icon: .back, size: 16, color: .blue)
            }
            Button(action: viewModel.nextPageResult) {
                NavIconView(icon: .forward, size: 16, color: .blue)
            }
            Button {
                withAnimation { viewModel.isShowingPageSearch = false }
                viewModel.pageSearchText = ""
            } label: {
                PlusIcon()
                    .stroke(.secondary, style: .init(lineWidth: 1.8, lineCap: .round))
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(45))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .liquidCapsule()
        .padding(.horizontal, 16)
    }

    // MARK: - Deslizar para cambiar pestaña

    private func handleTabSwipe(_ dx: CGFloat) {
        withAnimation(.spring(response: 0.3)) { dragOffsetX = 0 }
        let tabs   = viewModel.tabManager.tabs
        guard tabs.count > 1,
              let cur = viewModel.tabManager.activeTabID,
              let idx = tabs.firstIndex(where: { $0.id == cur }) else { return }

        if dx < -40 && idx < tabs.count - 1 {
            viewModel.selectTab(tabs[idx + 1].id)
        } else if dx > 40 && idx > 0 {
            viewModel.selectTab(tabs[idx - 1].id)
        }
    }
}
