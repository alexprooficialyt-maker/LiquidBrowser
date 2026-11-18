import SwiftUI

// MARK: - AppleSafariBottomBar (Floating Pill Liquid Glass Bar with Circular < and > Buttons)

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
            // 1. Omnibar Cápsula Central (Dirección / Búsqueda + Candado SSL + Recarga)
            searchOmnibarCapsule(theme: theme, scheme: scheme)

            // 2. Fila de Controles Safari con Botones Circulares Independientes < y >
            if !isEditingSearch {
                controlsRow(theme: theme, scheme: scheme, tabsCount: totalTabsCount)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            // Contenedor Flotante Estilo Píldora Liquid Glass de Apple
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                }
                .shadow(
                    color: scheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.10),
                    radius: 14,
                    x: 0,
                    y: 6
                )
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
        .animation(LiquidAnimation.interactiveSpring, value: isEditingSearch)
    }

    // MARK: - 1. Cápsula Omnibar Central

    @ViewBuilder
    private func searchOmnibarCapsule(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let currentTab = StorageEngine.shared.activeTab
        let isNewTab = currentTab?.isNewTab ?? true

        ZStack(alignment: .bottom) {
            HStack(spacing: 10) {
                // Candado de Seguridad Interactivo (SSL) en Web, o Icono Oficial de Buscador en Home/Búsqueda
                if isEditingSearch || isNewTab {
                    SearchEngineBarIconView(engine: SearchEngineType.active, size: 18)
                        .frame(width: 28, height: 28)
                } else {
                    Button {
                        HapticManager.shared.touchLight()
                        KeyboardDismissHelper.dismiss()
                        onOpenSSLInspector()
                    } label: {
                        AnimatedPadlockIcon(isSecure: coordinator.currentIsSecure, size: 16)
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                // Campo de Texto de Búsqueda / Dirección
                if isEditingSearch {
                    TextField(Loc.tr("bar_search_placeholder"), text: $searchInput)
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
                            Text(isNewTab ? Loc.tr("bar_search_placeholder") : (coordinator.currentDisplayTitle.isEmpty ? (currentTab?.displayHost ?? Loc.tr("bar_search_placeholder")) : coordinator.currentDisplayTitle))
                                .font(.system(size: 14, weight: isNewTab ? .regular : .medium, design: .rounded))
                                .foregroundStyle(isNewTab ? theme.textSecondary(for: scheme) : theme.textPrimary(for: scheme))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Botón Derecho: Limpiar/Cancelar si edita, o Recarga/Parar
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

                    Button(Loc.tr("cancel")) {
                        cancelSearch()
                    }
                    .font(.system(size: 13, weight: .semibold))
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
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(theme.surfaceElevated(for: scheme))
            .clipShape(Capsule())
            .overlay {
                Capsule().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
            }

            // Barra de Progreso en el Borde Inferior de la Cápsula
            if coordinator.currentIsLoading && coordinator.currentProgress > 0 && coordinator.currentProgress < 1.0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(theme.textPrimary(for: scheme))
                        .frame(width: geo.size.width * CGFloat(coordinator.currentProgress), height: 2)
                        .animation(LiquidAnimation.interactiveSpring, value: coordinator.currentProgress)
                }
                .frame(height: 2)
                .clipShape(Capsule())
                .padding(.horizontal, 6)
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
        KeyboardDismissHelper.dismiss()
    }

    private func commitSearch() {
        let query = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            coordinator.navigate(to: query)
        }
        cancelSearch()
    }

    // MARK: - 2. Fila de Controles Safari con Botones Circulares Independientes < y >

    @ViewBuilder
    private func controlsRow(theme: ThemeManager, scheme: ColorScheme, tabsCount: Int) -> some View {
        HStack(spacing: 0) {
            // Botón Circular Atrás (<)
            LiquidCircularButton(
                .chevronLeft,
                size: 38,
                iconSize: 16,
                isEnabled: coordinator.currentCanGoBack
            ) {
                coordinator.goBack()
            }

            Spacer()

            // Botón Circular Adelante (>)
            LiquidCircularButton(
                .chevronRight,
                size: 38,
                iconSize: 16,
                isEnabled: coordinator.currentCanGoForward
            ) {
                coordinator.goForward()
            }

            Spacer()

            // Botón Circular Herramientas (NUNCA compartir)
            LiquidCircularButton(
                .toolsMenu,
                size: 38,
                iconSize: 17,
                isEnabled: true
            ) {
                KeyboardDismissHelper.dismiss()
                onOpenTools()
            }

            Spacer()

            // Botón Circular Espacios / Pestañas con Contador Numérico
            Button {
                HapticManager.shared.touchMedium()
                KeyboardDismissHelper.dismiss()
                onOpenSpaces()
            } label: {
                ZStack {
                    Circle()
                        .fill(theme.surfaceElevated(for: scheme))
                        .frame(width: 38, height: 38)
                        .overlay {
                            Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                        }

                    LiquidIconView(.tabs, size: 19, color: theme.textPrimary(for: scheme))

                    // Contador numérico de pestañas
                    Text("\(tabsCount)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                        .offset(x: -0.5, y: 1.0)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Botón Circular Nueva Pestaña (+)
            LiquidCircularButton(
                .newTab,
                size: 38,
                iconSize: 17,
                isEnabled: true
            ) {
                KeyboardDismissHelper.dismiss()
                onNewTab()
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }
}
