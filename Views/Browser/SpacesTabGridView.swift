import SwiftUI

// MARK: - SpacesTabGridView (Carrusel Horizontal Deslizable & Menús Contextuales)

public struct SpacesTabGridView: View {
    @Bindable var coordinator: WebEngineCoordinator
    var onDismiss: () -> Void

    @State private var searchQuery: String = ""
    @State private var isShowingCreateSpace: Bool = false
    @State private var editingSpace: SpaceModel? = nil

    // Estado para edición rápida de título de pestaña
    @State private var editingTab: TabModel? = nil
    @State private var newTabTitleInput: String = ""

    // Estado para desbloqueo de Espacio Privado
    @State private var isPrivateUnlocked: Bool = false
    @State private var showingPrivateAuthError: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init(coordinator: WebEngineCoordinator, onDismiss: @escaping () -> Void) {
        self.coordinator = coordinator
        self.onDismiss = onDismiss
    }

    private var filteredTabs: [TabModel] {
        let inSpace = coordinator.tabsInActiveSpace
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return inSpace
        }
        let query = searchQuery.lowercased()
        return inSpace.filter {
            $0.displayTitle.lowercased().contains(query) || $0.displayHost.lowercased().contains(query)
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared

        ZStack {
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra Superior con Botón Cerrar y Título
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                // Carrusel Horizontal Deslizable de Espacios
                spacesCarouselView
                    .padding(.bottom, 14)

                // Buscador de Pestañas
                searchField
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Cuadrícula de Pestañas o Estado Vacío
                if coordinator.activeSpaceID == SpaceModel.privateSpaceID && !isPrivateUnlocked && KeychainSecurityHelper.shared.isAppLockEnabled {
                    privateLockedSpaceView(theme: theme)
                } else if filteredTabs.isEmpty {
                    emptySpaceView(theme: theme)
                } else {
                    tabsGridScrollView
                }

                // Barra Inferior de Acciones
                bottomBarActions
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $isShowingCreateSpace) {
            CreateSpaceSheet(coordinator: coordinator)
        }
        .sheet(item: $editingSpace) { space in
            CreateSpaceSheet(coordinator: coordinator, existingSpace: space)
        }
        .alert("Editar Título de Pestaña", isPresented: Binding<Bool>(
            get: { editingTab != nil },
            set: { if !$0 { editingTab = nil } }
        )) {
            TextField("Título personalizado", text: $newTabTitleInput)
            Button("Guardar") {
                if let tab = editingTab {
                    coordinator.renameTab(id: tab.id, newTitle: newTabTitleInput)
                }
                editingTab = nil
            }
            Button("Cancelar", role: .cancel) {
                editingTab = nil
            }
        }
    }

    // MARK: - Header Bar

    @ViewBuilder
    private var headerBar: some View {
        let theme = ThemeManager.shared

        HStack {
            Text("Pestañas")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Spacer()

            Button(action: {
                HapticManager.shared.touchLight()
                onDismiss()
            }) {
                LiquidIconView(.close, size: 16)
                    .padding(8)
                    .liquidGlass(config: .chip)
            }
        }
    }

    // MARK: - Carrusel Horizontal Deslizable de Espacios

    @ViewBuilder
    private var spacesCarouselView: some View {
        let theme = ThemeManager.shared

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(coordinator.spaces) { space in
                        let isSelected = (coordinator.activeSpaceID == space.id)

                        SpacePillItem(
                            space: space,
                            isSelected: isSelected,
                            colorScheme: colorScheme,
                            action: {
                                selectSpace(space)
                            }
                        )
                        .id(space.id)
                        .contextMenu {
                            // 1. Fijar como primera carpeta
                            Button(action: {
                                pinSpaceToFirst(space)
                            }) {
                                Label("Poner como Primera Carpeta", systemImage: "pin")
                            }

                            // 2. Editar
                            Button(action: {
                                editingSpace = space
                            }) {
                                Label("Editar Carpeta", systemImage: "pencil")
                            }

                            // 3. Renovar todas las pestañas
                            Button(action: {
                                reloadAllTabsInSpace(space)
                            }) {
                                Label("Renovar Todas las Pestañas", systemImage: "arrow.clockwise")
                            }

                            // 4. Eliminar carpeta
                            if space.id != SpaceModel.defaultSpaceID && space.id != SpaceModel.privateSpaceID {
                                Button(role: .destructive, action: {
                                    deleteSpace(space)
                                }) {
                                    Label("Eliminar Carpeta", systemImage: "trash")
                                }
                            }
                        }
                    }

                    // Botón para Crear Nuevo Espacio
                    Button(action: {
                        HapticManager.shared.touchLight()
                        isShowingCreateSpace = true
                    }) {
                        HStack(spacing: 6) {
                            LiquidIconView(.newTab, size: 13)
                            Text("Nuevo Espacio")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .liquidGlass(config: .chip)
                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .pressableFeedback()
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: coordinator.activeSpaceID) { _, newID in
                withAnimation(LiquidAnimation.interactiveSpring) {
                    proxy.scrollTo(newID, anchor: .center)
                }
            }
        }
    }

    // MARK: - Search Field

    @ViewBuilder
    private var searchField: some View {
        let theme = ThemeManager.shared

        HStack(spacing: 10) {
            LiquidIconView(.search, size: 14, color: theme.textSecondary(for: colorScheme))

            TextField("Buscar en pestañas...", text: $searchQuery)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            if !searchQuery.isEmpty {
                Button(action: {
                    HapticManager.shared.touchLight()
                    searchQuery = ""
                }) {
                    LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(config: .card)
    }

    // MARK: - Tabs Grid Scroll View

    @ViewBuilder
    private var tabsGridScrollView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 14) {
                ForEach(filteredTabs) { tab in
                    tabCard(for: tab)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Tab Card con Menú Contextual Completo

    @ViewBuilder
    private func tabCard(for tab: TabModel) -> some View {
        let isSelected = (coordinator.activeTabID == tab.id)
        let theme = ThemeManager.shared

        Button(action: {
            HapticManager.shared.touchLight()
            coordinator.selectTab(id: tab.id)
            onDismiss()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header de la Tarjeta con Título, Icono de Fijado y Botón Cerrar
                HStack(spacing: 6) {
                    if tab.isPinned {
                        LiquidIconView(.pin, size: 11, color: theme.textPrimary(for: colorScheme))
                    }

                    Text(tab.displayTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    Spacer()

                    Button(action: {
                        HapticManager.shared.touchLight()
                        coordinator.closeTab(id: tab.id)
                    }) {
                        LiquidIconView(.close, size: 10, color: theme.textSecondary(for: colorScheme))
                            .padding(4)
                            .background(theme.cardBackground(for: colorScheme))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(theme.cardBackground(for: colorScheme))

                // Snapshot Real o Placeholder
                ZStack {
                    if let snapFile = tab.snapshotFileName,
                       let uiImg = StorageEngine.shared.loadSnapshot(fileName: snapFile) {
                        Image(uiImage: uiImg)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .frame(height: 120)
                            .overlay {
                                Text(tab.displayHost)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textTertiary(for: colorScheme))
                            }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        tabCardBorder(isSelected: isSelected, theme: theme),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            }
            .shadow(
                color: theme.shadowColor(for: colorScheme).opacity(isSelected ? 0.35 : 0.15),
                radius: isSelected ? 12 : 6,
                y: 3
            )
        }
        .pressableFeedback()
        .contextMenu {
            // 1. Fijar arriba (Poner primero)
            Button(action: {
                if tab.isPinned {
                    coordinator.unpinTab(id: tab.id)
                } else {
                    coordinator.pinTabToTop(id: tab.id)
                }
            }) {
                Label(tab.isPinned ? "Desfijar Pestaña" : "Fijar Arriba (Poner Primero)", systemImage: tab.isPinned ? "pin.slash" : "pin")
            }

            // 2. Editar
            Button(action: {
                editingTab = tab
                newTabTitleInput = tab.displayTitle
            }) {
                Label("Editar Título", systemImage: "pencil")
            }

            // 3. Renovar (Recargar)
            Button(action: {
                let wv = TabPoolManager.shared.webView(for: tab)
                wv.reload()
                HapticManager.shared.touchLight()
            }) {
                Label("Renovar (Recargar)", systemImage: "arrow.clockwise")
            }

            // 4. Mover a Carpeta
            Menu("Mover a Espacio") {
                ForEach(coordinator.spaces.filter { $0.id != tab.spaceID }) { targetSpace in
                    Button(targetSpace.name) {
                        coordinator.moveTab(id: tab.id, toSpace: targetSpace.id)
                        HapticManager.shared.touchLight()
                    }
                }
            }

            // 5. Eliminar
            Button(role: .destructive, action: {
                coordinator.closeTab(id: tab.id)
            }) {
                Label("Eliminar Pestaña", systemImage: "trash")
            }
        }
    }

    // MARK: - Estado Vacío

    @ViewBuilder
    private func emptySpaceView(theme: ThemeManager) -> some View {
        VStack(spacing: 16) {
            Spacer()

            LiquidIconView(.spaceFolder, size: 48, color: theme.textSecondary(for: colorScheme).opacity(0.6))

            Text("No hay pestañas en este espacio")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Text("Abre una nueva pestaña para comenzar a explorar.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                _ = coordinator.createNewTab(in: coordinator.activeSpaceID)
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    LiquidIconView(.newTab, size: 14, color: colorScheme == .dark ? Color.black : Color.white)
                    Text("Abrir Nueva Pestaña")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            }
            .pressableFeedback()
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Bloqueo de Espacio Privado

    @ViewBuilder
    private func privateLockedSpaceView(theme: ThemeManager) -> some View {
        VStack(spacing: 18) {
            Spacer()

            LiquidIconView(.spacePrivate, size: 52, color: theme.textPrimary(for: colorScheme))

            Text("Espacio Privado Protegido")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Text("Se requiere autenticación para acceder a tus pestañas privadas.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Button(action: {
                unlockPrivateSpace()
            }) {
                HStack(spacing: 8) {
                    LiquidIconView(KeychainSecurityHelper.shared.biometricType == .faceID ? .faceID : .touchID,
                                   size: 18,
                                   color: colorScheme == .dark ? Color.black : Color.white)
                    Text("Desbloquear Espacio")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            }
            .pressableFeedback()

            Spacer()
        }
    }

    // MARK: - Bottom Bar Actions

    @ViewBuilder
    private var bottomBarActions: some View {
        let theme = ThemeManager.shared

        HStack {
            Text("\(filteredTabs.count) abierta\(filteredTabs.count == 1 ? "" : "s")")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))

            Spacer()

            Button(action: {
                _ = coordinator.createNewTab(in: coordinator.activeSpaceID)
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    LiquidIconView(.newTab, size: 14, color: colorScheme == .dark ? Color.black : Color.white)
                    Text("Nueva")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            }
            .pressableFeedback()
        }
    }

    // MARK: - Helpers

    private func tabCardBorder(isSelected: Bool, theme: ThemeManager) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(colorScheme == .dark ? Color.white : Color.black)
        } else {
            return AnyShapeStyle(theme.borderSpecular(for: colorScheme))
        }
    }

    private func selectSpace(_ space: SpaceModel) {
        HapticManager.shared.selectionChanged()
        if space.id == SpaceModel.privateSpaceID && !isPrivateUnlocked && KeychainSecurityHelper.shared.isAppLockEnabled {
            coordinator.activeSpaceID = space.id
            unlockPrivateSpace()
        } else {
            coordinator.activeSpaceID = space.id
        }
    }

    private func unlockPrivateSpace() {
        if KeychainSecurityHelper.shared.isBiometricAuthEnabled {
            KeychainSecurityHelper.shared.authenticateWithBiometrics(reason: "Desbloquear Espacio Privado") { success in
                if success {
                    self.isPrivateUnlocked = true
                    HapticManager.shared.notifySuccess()
                }
            }
        } else {
            self.isPrivateUnlocked = true
        }
    }

    private func pinSpaceToFirst(_ space: SpaceModel) {
        guard let idx = coordinator.spaces.firstIndex(where: { $0.id == space.id }) else { return }
        var item = coordinator.spaces.remove(at: idx)
        item.isPinned = true
        coordinator.spaces.insert(item, at: 0)
        coordinator.saveSpaces()
        HapticManager.shared.notifySuccess()
    }

    private func reloadAllTabsInSpace(_ space: SpaceModel) {
        let spaceTabs = coordinator.tabs.filter { $0.spaceID == space.id }
        for tab in spaceTabs {
            let wv = TabPoolManager.shared.webView(for: tab)
            wv.reload()
        }
        HapticManager.shared.touchLight()
    }

    private func deleteSpace(_ space: SpaceModel) {
        coordinator.spaces.removeAll { $0.id == space.id }
        let spaceTabs = coordinator.tabs.filter { $0.spaceID == space.id }
        for tab in spaceTabs {
            coordinator.closeTab(id: tab.id)
        }
        coordinator.saveSpaces()
        coordinator.activeSpaceID = SpaceModel.defaultSpaceID
        HapticManager.shared.touchMedium()
    }
}

// MARK: - SpacePillItem Helper

public struct SpacePillItem: View {
    public let space: SpaceModel
    public let isSelected: Bool
    public let colorScheme: ColorScheme
    public let action: () -> Void

    public init(space: SpaceModel, isSelected: Bool, colorScheme: ColorScheme, action: @escaping () -> Void) {
        self.space = space
        self.isSelected = isSelected
        self.colorScheme = colorScheme
        self.action = action
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let iconType = LiquidIconType(rawValue: space.iconTypeRaw) ?? .spaceFolder
        let fgColor = isSelected ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme)
        let bgColor = isSelected ? (colorScheme == .dark ? Color.white : Color.black) : Color.white.opacity(colorScheme == .dark ? 0.06 : 0.60)

        Button(action: action) {
            HStack(spacing: 8) {
                if space.isPinned {
                    LiquidIconView(.pin, size: 10, color: fgColor)
                }

                LiquidIconView(iconType, size: 14, color: fgColor)

                Text(space.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(fgColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(bgColor)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? AnyShapeStyle(Color.clear) : AnyShapeStyle(theme.borderSpecular(for: colorScheme)),
                        lineWidth: 0.5
                    )
            }
        }
        .pressableFeedback()
    }
}
