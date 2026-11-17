import SwiftUI

// MARK: - FloatingGlassCapsule (Barra Inferior Fija Monocroma 19pt)

public struct FloatingGlassCapsule: View {
    @Bindable var coordinator: WebEngineCoordinator
    var onOpenTabs: () -> Void
    var onOpenTools: () -> Void

    @State private var isEditingURL: Bool = false
    @State private var urlInputText: String = ""
    @State private var barDragOffset: CGFloat = 0

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFieldFocused: Bool

    public init(
        coordinator: WebEngineCoordinator,
        onOpenTabs: @escaping () -> Void,
        onOpenTools: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.onOpenTabs = onOpenTabs
        self.onOpenTools = onOpenTools
    }

    public var body: some View {
        let theme = ThemeManager.shared

        VStack(spacing: 0) {
            // Línea luminosa de progreso de 2pt en el borde superior
            if coordinator.currentIsLoading {
                progressBar(theme: theme)
            }

            HStack(spacing: 8) {
                if !isEditingURL {
                    // Atrás
                    LiquidIconButton(.back, size: 36, iconSize: 15) {
                        coordinator.goBack()
                    }
                    .disabled(!coordinator.currentCanGoBack)
                    .opacity(coordinator.currentCanGoBack ? 1.0 : 0.3)

                    // Adelante
                    LiquidIconButton(.forward, size: 36, iconSize: 15) {
                        coordinator.goForward()
                    }
                    .disabled(!coordinator.currentCanGoForward)
                    .opacity(coordinator.currentCanGoForward ? 1.0 : 0.3)
                }

                // Campo Central de URL / Búsqueda
                centerURLBar(theme: theme)

                if isEditingURL {
                    Button("Cancelar") {
                        HapticManager.shared.touchLight()
                        isFieldFocused = false
                        withAnimation(LiquidAnimation.interactiveSpring) {
                            isEditingURL = false
                        }
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                    .padding(.trailing, 4)
                } else {
                    // Herramientas / Compartir
                    LiquidIconButton(.share, size: 36, iconSize: 15) {
                        onOpenTools()
                    }

                    // Gestor de Pestañas con Badge Numérico
                    LiquidIconButton(.tabs, size: 36, iconSize: 15) {
                        onOpenTabs()
                    }
                    .overlay(alignment: .topTrailing) {
                        let count = coordinator.tabsInActiveSpace.count
                        if count > 1 {
                            Text("\(count)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background {
                                    Capsule().fill(colorScheme == .dark ? Color.white : Color.black)
                                }
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .liquidGlass(config: .capsuleBar)
        .padding(.horizontal, 16)
        .gesture(
            DragGesture(minimumDistance: 25)
                .onChanged { val in
                    barDragOffset = val.translation.width
                }
                .onEnded { val in
                    handleHorizontalSwipe(dx: val.translation.width)
                    barDragOffset = 0
                }
        )
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private func progressBar(theme: ThemeManager) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)

                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(theme.progressHighlight(for: colorScheme))
                    .frame(width: max(0, geo.size.width * coordinator.currentProgress), height: 2.0)
                    .animation(LiquidAnimation.progressEase, value: coordinator.currentProgress)
            }
        }
        .frame(height: 2.0)
        .padding(.horizontal, 19)
    }

    // MARK: - Center URL Bar

    @ViewBuilder
    private func centerURLBar(theme: ThemeManager) -> some View {
        HStack(spacing: 8) {
            // Candado SSL
            LiquidIconView(
                coordinator.currentIsSecure ? .lockSSL : .unlockSSL,
                size: 13,
                color: coordinator.currentIsSecure ?
                    theme.textSecondary(for: colorScheme) :
                    Color.red.opacity(0.85)
            )

            if isEditingURL {
                TextField("Buscar o escribir URL...", text: $urlInputText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                    .keyboardType(.webSearch)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFieldFocused)
                    .submitLabel(.go)
                    .onSubmit {
                        submitURL()
                    }

                if !urlInputText.isEmpty {
                    Button(action: {
                        HapticManager.shared.touchLight()
                        urlInputText = ""
                    }) {
                        LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                    }
                }
            } else {
                Button(action: {
                    HapticManager.shared.touchLight()
                    urlInputText = coordinator.currentURLString
                    withAnimation(LiquidAnimation.interactiveSpring) {
                        isEditingURL = true
                        isFieldFocused = true
                    }
                }) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(coordinator.currentDisplayTitle.isEmpty ? "Buscar o escribir URL" : coordinator.currentDisplayTitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                            .lineLimit(1)

                        if !coordinator.currentURLString.isEmpty {
                            Text(coordinator.activeTab?.displayHost ?? "")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if !isEditingURL {
                // Botón de recarga rápida
                Button(action: {
                    HapticManager.shared.touchLight()
                    if coordinator.currentIsLoading {
                        coordinator.stop()
                    } else {
                        coordinator.reload()
                    }
                }) {
                    LiquidIconView(coordinator.currentIsLoading ? .stop : .reload, size: 13, color: theme.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.cardBackground(for: colorScheme))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
        }
    }

    // MARK: - Actions

    private func submitURL() {
        let input = urlInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        HapticManager.shared.touchMedium()
        isFieldFocused = false
        withAnimation(LiquidAnimation.interactiveSpring) {
            isEditingURL = false
        }
        coordinator.navigate(to: input)
    }

    private func handleHorizontalSwipe(dx: CGFloat) {
        let spaceTabs = coordinator.tabsInActiveSpace
        guard spaceTabs.count > 1, let currentID = coordinator.activeTabID else { return }
        guard let currentIndex = spaceTabs.firstIndex(where: { $0.id == currentID }) else { return }

        if dx < -50 && currentIndex < spaceTabs.count - 1 {
            // Deslizar izquierda -> Pestaña siguiente
            HapticManager.shared.touchLight()
            coordinator.selectTab(id: spaceTabs[currentIndex + 1].id)
        } else if dx > 50 && currentIndex > 0 {
            // Deslizar derecha -> Pestaña anterior
            HapticManager.shared.touchLight()
            coordinator.selectTab(id: spaceTabs[currentIndex - 1].id)
        }
    }
}
