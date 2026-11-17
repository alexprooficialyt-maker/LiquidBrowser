import SwiftUI

// MARK: - AppleSafariBottomBar (Full-Width Search Capsule + Original Safari Controls)

public struct AppleSafariBottomBar: View {
    @Environment(\.colorScheme) private var systemColorScheme

    public var coordinator: WebEngineCoordinator
    public var onOpenSSLInspector: () -> Void
    public var onOpenTools: () -> Void
    public var onOpenSpaces: () -> Void
    public var onNewTab: () -> Void

    @State private var isEditingSearch: Bool = false
    @State private var searchInput: String = ""
    @FocusState private var isSearchFieldFocused: Bool

    public init(
        coordinator: WebEngineCoordinator,
        onOpenSSLInspector: @escaping () -> Void,
        onOpenTools: @escaping () -> Void,
        onOpenSpaces: @escaping () -> Void,
        onNewTab: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.onOpenSSLInspector = onOpenSSLInspector
        self.onOpenTools = onOpenTools
        self.onOpenSpaces = onOpenSpaces
        self.onNewTab = onNewTab
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let totalTabsCount = StorageEngine.shared.tabsForActiveProfile().count

        VStack(spacing: 8) {
            // 1. Buscador Protagonista de Ancho Completo
            searchCapsule(theme: theme, scheme: scheme)
                .padding(.horizontal, 16)

            // 2. Fila Inferior Original de Apple Safari
            safariControlsRow(theme: theme, scheme: scheme, tabsCount: totalTabsCount)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
        }
        .padding(.top, 8)
        .background {
            // Fondo de cristal translúcido ultraThinMaterial con borde especular superior
            VStack(spacing: 0) {
                Divider()
                    .background(theme.borderSpecular(for: scheme))
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - 1. Cápsula del Buscador Protagonista a Todo lo Ancho

    @ViewBuilder
    private func searchCapsule(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let currentTab = StorageEngine.shared.activeTab
        let isNewTab = currentTab?.isNewTab ?? true

        ZStack(alignment: .bottom) {
            HStack(spacing: 10) {
                // Candado de Seguridad Interactivo (SSL Inspector)
                Button {
                    HapticManager.shared.touchLight()
                    onOpenSSLInspector()
                } label: {
                    AnimatedPadlockIcon(isSecure: coordinator.currentIsSecure, size: 16)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Campo de Texto de Búsqueda / Dirección
                if isEditingSearch {
                    TextField(Loc.tr("search_placeholder"), text: $searchInput)
                        .focused($isSearchFieldFocused)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.webSearch)
                        .submitLabel(.go)
                        .onSubmit {
                            commitSearch()
                        }
                } else {
                    Button {
                        HapticManager.shared.touchLight()
                        beginSearch()
                    } label: {
                        HStack(spacing: 6) {
                            Text(isNewTab ? Loc.tr("search_placeholder") : (coordinator.currentDisplayTitle.isEmpty ? (currentTab?.displayHost ?? Loc.tr("search_placeholder")) : coordinator.currentDisplayTitle))
                                .font(.system(size: 15, weight: isNewTab ? .regular : .medium, design: .rounded))
                                .foregroundStyle(isNewTab ? theme.textSecondary(for: scheme) : theme.textPrimary(for: scheme))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Botón Derecho: Limpiar si edita, o Recarga/Parar
                if isEditingSearch {
                    if !searchInput.isEmpty {
                        Button {
                            HapticManager.shared.touchLight()
                            searchInput = ""
                        } label: {
                            LiquidIconView(.close, size: 14, color: theme.textSecondary(for: scheme))
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Cancelar") {
                        cancelSearch()
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.textPrimary(for: scheme))
                } else {
                    // Botón de Recarga / Parar
                    Button {
                        HapticManager.shared.touchLight()
                        if coordinator.currentIsLoading {
                            coordinator.stop()
                        } else {
                            coordinator.reload()
                        }
                    } label: {
                        AnimatedReloadIcon(isLoading: coordinator.currentIsLoading, size: 16)
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .liquidGlassCapsule(cornerRadius: 16)

            // Barra de Progreso en el Borde Inferior de la Cápsula
            if coordinator.currentIsLoading && coordinator.currentProgress > 0 && coordinator.currentProgress < 1.0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(theme.textPrimary(for: scheme))
                        .frame(width: geo.size.width * CGFloat(coordinator.currentProgress), height: 2)
                        .animation(LiquidAnimation.interactiveSpring, value: coordinator.currentProgress)
                }
                .frame(height: 2)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 2)
            }
        }
    }

    private func beginSearch() {
        searchInput = coordinator.currentURLString
        isEditingSearch = true
        isSearchFieldFocused = true
    }

    private func cancelSearch() {
        isEditingSearch = false
        isSearchFieldFocused = false
        searchInput = ""
    }

    private func commitSearch() {
        let query = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            coordinator.navigate(to: query)
        }
        cancelSearch()
    }

    // MARK: - 2. Fila Inferior Original de Apple Safari

    @ViewBuilder
    private func safariControlsRow(theme: ThemeManager, scheme: ColorScheme, tabsCount: Int) -> some View {
        HStack {
            // 1. Atrás
            Button {
                HapticManager.shared.touchLight()
                coordinator.goBack()
            } label: {
                LiquidIconView(.back, size: 20, color: coordinator.currentCanGoBack ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.25))
                    .frame(width: 44, height: 38)
            }
            .buttonStyle(.plain)
            .disabled(!coordinator.currentCanGoBack)

            Spacer()

            // 2. Adelante
            Button {
                HapticManager.shared.touchLight()
                coordinator.goForward()
            } label: {
                LiquidIconView(.forward, size: 20, color: coordinator.currentCanGoForward ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.25))
                    .frame(width: 44, height: 38)
            }
            .buttonStyle(.plain)
            .disabled(!coordinator.currentCanGoForward)

            Spacer()

            // 3. Botón de Herramientas (Icono original de ajustes/controles de Safari, NUNCA compartir)
            Button {
                HapticManager.shared.touchLight()
                onOpenTools()
            } label: {
                LiquidIconView(.toolsMenu, size: 20, color: theme.textPrimary(for: scheme))
                    .frame(width: 44, height: 38)
            }
            .buttonStyle(.plain)

            Spacer()

            // 4. Espacios / Pestañas con Contador Dinámico
            Button {
                HapticManager.shared.touchMedium()
                onOpenSpaces()
            } label: {
                ZStack {
                    LiquidIconView(.tabs, size: 20, color: theme.textPrimary(for: scheme))

                    // Contador numérico de pestañas
                    Text("\(tabsCount)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                        .offset(x: -0.5, y: 1.0)
                }
                .frame(width: 44, height: 38)
            }
            .buttonStyle(.plain)

            Spacer()

            // 5. Nueva Pestaña (+)
            Button {
                HapticManager.shared.touchLight()
                onNewTab()
            } label: {
                LiquidIconView(.newTab, size: 20, color: theme.textPrimary(for: scheme))
                    .frame(width: 44, height: 38)
            }
            .buttonStyle(.plain)
        }
    }
}
