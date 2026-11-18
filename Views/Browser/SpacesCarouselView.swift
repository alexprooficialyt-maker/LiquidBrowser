import SwiftUI

// MARK: - SpacesCarouselView (Horizontal Spaces Carousel + Tab Grid with Context Menus)

public struct SpacesCarouselView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    public var coordinator: WebEngineCoordinator

    @State private var storage = StorageEngine.shared
    @State private var selectedSpaceID: UUID?
    @State private var isCreatingSpace: Bool = false
    @State private var newSpaceName: String = ""
    @State private var newSpaceIcon: LiquidIconType = .spaceFolder
    @State private var newSpaceColor: ProfileAccentColor = .monochrome
    @State private var isPrivateUnlocked: Bool = false

    public init(coordinator: WebEngineCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let activeSpaces = storage.spacesForActiveProfile()

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 16) {
                    // 1. Carrusel Horizontal de Espacios
                    spacesCarousel(spaces: activeSpaces, theme: theme, scheme: scheme)
                        .padding(.top, 12)

                    // 2. Cuadrícula de Pestañas del Espacio Seleccionado
                    let currentSpaceID = selectedSpaceID ?? activeSpaces.first?.id
                    let currentSpace = activeSpaces.first(where: { $0.id == currentSpaceID })

                    if currentSpace?.isPrivate == true && !isPrivateUnlocked && KeychainVault.shared.isBiometricAuthEnabled {
                        privateSpaceLockView(theme: theme, scheme: scheme)
                    } else {
                        tabsGrid(forSpaceID: currentSpaceID, theme: theme, scheme: scheme)
                    }
                }
            }
            .navigationTitle(Loc.tr("spaces_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("done")) {
                        dismiss()
                    }
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        HapticManager.shared.touchLight()
                        let newTab = coordinator.createNewTab(inSpace: selectedSpaceID)
                        coordinator.selectTab(id: newTab.id)
                        dismiss()
                    } label: {
                        LiquidIconView(.newTab, size: 18, color: theme.textPrimary(for: scheme))
                    }
                }
            }
            .onAppear {
                KeyboardDismissHelper.dismiss()
                if selectedSpaceID == nil {
                    selectedSpaceID = activeSpaces.first?.id
                }
            }
            .sheet(isPresented: $isCreatingSpace) {
                createSpaceSheet(theme: theme, scheme: scheme)
            }
        }
    }

    // MARK: - 1. Carrusel Horizontal de Espacios

    @ViewBuilder
    private func spacesCarousel(spaces: [SpaceModel], theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(spaces) { space in
                    let isSelected = (selectedSpaceID == space.id)

                    Button {
                        HapticManager.shared.touchSelection()
                        selectedSpaceID = space.id
                        if space.isPrivate && KeychainVault.shared.isBiometricAuthEnabled && !isPrivateUnlocked {
                            unlockPrivateSpace()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            LiquidIconView(space.icon, size: 16, color: isSelected ? (scheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: scheme))

                            Text(space.name)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? (scheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: scheme))

                            if space.isPinned {
                                LiquidIconView(.pin, size: 10, color: isSelected ? (scheme == .dark ? Color.black : Color.white) : theme.textSecondary(for: scheme))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(scheme == .dark ? Color.white : Color.black)
                            } else {
                                Capsule()
                                    .fill(theme.surfaceElevated(for: scheme))
                                    .overlay {
                                        Capsule().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                                    }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        // Menú Contextual de Espacio: Fijar primero / Renovar / Editar / Eliminar
                        Button {
                            HapticManager.shared.touchLight()
                            storage.pinSpaceToFirst(id: space.id)
                        } label: {
                            Label(Loc.tr("spaces_pin_first"), systemImage: "pin")
                        }

                        Button {
                            HapticManager.shared.touchLight()
                            reloadAllTabs(in: space.id)
                        } label: {
                            Label(Loc.tr("spaces_renew_tabs"), systemImage: "arrow.clockwise")
                        }

                        Button {
                            HapticManager.shared.touchLight()
                            newSpaceName = space.name
                            newSpaceIcon = space.icon
                            newSpaceColor = space.colorAccent
                            isCreatingSpace = true
                        } label: {
                            Label(Loc.tr("spaces_edit_folder"), systemImage: "pencil")
                        }

                        if spaces.count > 1 {
                            Button(role: .destructive) {
                                HapticManager.shared.notifyWarning()
                                storage.deleteSpace(id: space.id)
                                if selectedSpaceID == space.id {
                                    selectedSpaceID = spaces.first?.id
                                }
                            } label: {
                                Label(Loc.tr("spaces_delete_folder"), systemImage: "trash")
                            }
                        }
                    }
                }

                // Botón Añadir Espacio (+)
                Button {
                    HapticManager.shared.touchLight()
                    KeyboardDismissHelper.dismiss()
                    isCreatingSpace = true
                } label: {
                    HStack(spacing: 4) {
                        LiquidIconView(.newTab, size: 14, color: theme.textSecondary(for: scheme))
                        Text(Loc.tr("spaces_new_folder"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.textSecondary(for: scheme))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(theme.surfaceElevated(for: scheme))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - 2. Cuadrícula de Pestañas

    @ViewBuilder
    private func tabsGrid(forSpaceID spaceID: UUID?, theme: ThemeManager, scheme: ColorScheme) -> some View {
        let tabs = storage.tabsForSpace(spaceID)

        if tabs.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                LiquidIconView(.tabs, size: 36, color: theme.textSecondary(for: scheme))
                Text("No hay pestañas en este espacio")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: scheme))

                Button("Abrir nueva pestaña") {
                    HapticManager.shared.touchLight()
                    let tab = coordinator.createNewTab(inSpace: spaceID)
                    coordinator.selectTab(id: tab.id)
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.textPrimary(for: scheme))
                .padding(.top, 4)

                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(tabs) { tab in
                        let isActive = (tab.id == storage.activeTabID)

                        Button {
                            HapticManager.shared.touchLight()
                            coordinator.selectTab(id: tab.id)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    if tab.isPinned {
                                        LiquidIconView(.pin, size: 12, color: theme.textPrimary(for: scheme))
                                    }

                                    Text(tab.displayHost)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                        .lineLimit(1)

                                    Spacer()

                                    // Botón Cerrar
                                    Button {
                                        HapticManager.shared.touchLight()
                                        coordinator.closeTab(id: tab.id)
                                    } label: {
                                        LiquidIconView(.close, size: 12, color: theme.textSecondary(for: scheme))
                                            .frame(width: 22, height: 22)
                                    }
                                    .buttonStyle(.plain)
                                }

                                Spacer(minLength: 40)

                                Text(tab.displayTitle)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))
                                    .lineLimit(2)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .liquidGlassCard(cornerRadius: 18)
                            .overlay {
                                if isActive {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 2)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            // Menú contextual de pestaña
                            Button {
                                storage.togglePinTab(id: tab.id)
                            } label: {
                                Label(tab.isPinned ? "Desfijar Pestaña" : "Fijar al Inicio", systemImage: "pin")
                            }

                            // Mover a otro espacio
                            Menu(Loc.tr("space_move_tab")) {
                                ForEach(storage.spacesForActiveProfile()) { otherSpace in
                                    Button(otherSpace.name) {
                                        storage.moveTab(id: tab.id, toSpace: otherSpace.id)
                                    }
                                }
                            }

                            Button(role: .destructive) {
                                coordinator.closeTab(id: tab.id)
                            } label: {
                                Label(Loc.tr("delete"), systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    // MARK: - Vista de Desbloqueo de Espacio Privado

    @ViewBuilder
    private func privateSpaceLockView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 16) {
            Spacer()
            LiquidIconView(.spacePrivate, size: 48, color: theme.textPrimary(for: scheme))

            Text("Espacio Privado Protegido")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))

            Text("Se requiere autenticación para ver estas pestañas.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondary(for: scheme))

            Button("Desbloquear con Biometría") {
                unlockPrivateSpace()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(scheme == .dark ? Color.black : Color.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(scheme == .dark ? Color.white : Color.black)
            .clipShape(Capsule())
            .padding(.top, 8)

            Spacer()
        }
    }

    private func unlockPrivateSpace() {
        KeychainVault.shared.authenticateWithBiometrics(reason: "Desbloquear Espacio Privado") { success in
            if success {
                Task { @MainActor in
                    self.isPrivateUnlocked = true
                    HapticManager.shared.notifySuccess()
                }
            }
        }
    }

    private func reloadAllTabs(in spaceID: UUID) {
        let tabs = storage.tabsForSpace(spaceID)
        for tab in tabs {
            let wv = TabPoolManager.shared.webView(for: tab)
            wv.reload()
        }
        HapticManager.shared.notifySuccess()
    }

    // MARK: - Sheet para Crear Nuevo Espacio

    @ViewBuilder
    private func createSpaceSheet(theme: ThemeManager, scheme: ColorScheme) -> some View {
        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre del Espacio")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField("Ej. Proyectos, Lectura", text: $newSpaceName)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    // Selector de Icono
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icono")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        let spaceIcons: [LiquidIconType] = [.spaceFolder, .spaceWork, .spaceStudy, .spaceCode, .spacePrivate, .spaceStar]
                        HStack(spacing: 14) {
                            ForEach(spaceIcons, id: \.self) { icon in
                                Button {
                                    newSpaceIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(theme.surfaceElevated(for: scheme))
                                            .frame(width: 44, height: 44)
                                            .overlay {
                                                if newSpaceIcon == icon {
                                                    Circle().strokeBorder(theme.textPrimary(for: scheme), lineWidth: 2)
                                                }
                                            }

                                        LiquidIconView(icon, size: 20, color: theme.textPrimary(for: scheme))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(Loc.tr("space_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("cancel")) { isCreatingSpace = false }
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("save")) {
                        let name = newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        let created = storage.createSpace(name: name, icon: newSpaceIcon, isPrivate: false, color: newSpaceColor)
                        selectedSpaceID = created.id
                        isCreatingSpace = false
                    }
                    .disabled(newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }
}

// MARK: - Compatibility Bridge
public typealias SpacesTabGridView = SpacesCarouselView
