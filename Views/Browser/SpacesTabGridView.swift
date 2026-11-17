import SwiftUI

public struct SpacesTabGridView: View {
    @Bindable var coordinator: WebEngineCoordinator
    var onDismiss: () -> Void

    @State private var searchQuery: String = ""
    @State private var isShowingCreateSpace: Bool = false
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
        let theme = ThemeEngine.shared

        ZStack {
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                spacesSelector
                    .padding(.bottom, 14)

                searchField
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                if filteredTabs.isEmpty {
                    emptySpaceView
                } else {
                    tabsGridScrollView
                }

                bottomBarActions
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $isShowingCreateSpace) {
            CreateSpaceSheet(isPresented: $isShowingCreateSpace) { name, icon in
                let newSpace = SpaceModel(
                    name: name,
                    iconTypeRaw: icon.rawValue,
                    isPrivate: false,
                    isLocked: false,
                    orderIndex: coordinator.spaces.count
                )
                coordinator.spaces.append(newSpace)
                coordinator.activeSpaceID = newSpace.id
                coordinator.saveSpaces()
            }
        }
    }

    @ViewBuilder
    private var headerBar: some View {
        HStack {
            Text("Pestañas y Espacios")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

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

    @ViewBuilder
    private var spacesSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(coordinator.spaces) { space in
                    let isSelected = (coordinator.activeSpaceID == space.id)
                    let iconType = LiquidIconType(rawValue: space.iconTypeRaw) ?? .spaceFolder

                    Button(action: {
                        HapticManager.shared.selectionChanged()
                        coordinator.activeSpaceID = space.id
                    }) {
                        HStack(spacing: 8) {
                            LiquidIconView(
                                iconType,
                                size: 14,
                                color: isSelected ? (colorScheme == .dark ? Color.black : Color.white) : ThemeEngine.shared.textPrimary(for: colorScheme)
                            )

                            Text(space.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(
                                    isSelected ? (colorScheme == .dark ? Color.black : Color.white) : ThemeEngine.shared.textPrimary(for: colorScheme)
                                )
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? (colorScheme == .dark ? Color.white : Color.black) : Color.white.opacity(colorScheme == .dark ? 0.06 : 0.60))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    isSelected ? Color.clear : ThemeEngine.shared.borderSpecular(for: colorScheme),
                                    lineWidth: 0.5
                                )
                        }
                    }
                    .pressableFeedback()
                }

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
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                }
                .pressableFeedback()
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 10) {
            LiquidIconView(.search, size: 14, color: ThemeEngine.shared.textSecondary(for: colorScheme))

            TextField("Buscar en este espacio…", text: $searchQuery)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))
                .autocorrectionDisabled()

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    LiquidIconView(.close, size: 12, color: ThemeEngine.shared.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(config: .card)
    }

    @ViewBuilder
    private var emptySpaceView: some View {
        Spacer()
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                    .frame(width: 80, height: 80)

                LiquidIconView(.spaceFolder, size: 32, color: ThemeEngine.shared.textSecondary(for: colorScheme))
            }

            VStack(spacing: 6) {
                Text("Espacio Vacío")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Text("Abre una nueva pestaña en este espacio.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
            }

            Button(action: {
                _ = coordinator.createNewTab(in: coordinator.activeSpaceID)
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    LiquidIconView(.newTab, size: 14)
                    Text("Abrir Pestaña")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            }
            .pressableFeedback()
        }
        Spacer()
    }

    @ViewBuilder
    private var tabsGridScrollView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 14) {
                ForEach(filteredTabs) { tab in
                    tabGridCard(tab: tab)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func tabGridCard(tab: TabModel) -> some View {
        let isSelected = (coordinator.activeTabID == tab.id)
        let theme = ThemeEngine.shared

        Button(action: {
            HapticManager.shared.touchLight()
            coordinator.selectTab(id: tab.id)
            onDismiss()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    LiquidIconView(tab.isSecure ? .lockSSL : .unlockSSL, size: 12, color: theme.textSecondary(for: colorScheme))

                    Text(tab.displayTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    Spacer()

                    Button(action: {
                        HapticManager.shared.touchLight()
                        coordinator.closeTab(id: tab.id)
                    }) {
                        LiquidIconView(.close, size: 11, color: theme.textSecondary(for: colorScheme))
                            .padding(4)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))

                ZStack {
                    if let snap = tab.snapshotFileName, let img = StorageEngine.shared.loadSnapshot(fileName: snap) {
                        Image(uiImage: img)
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
                        isSelected ?
                        (colorScheme == .dark ? Color.white : Color.black) :
                        theme.borderSpecular(for: colorScheme),
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
            Button(action: {
                if let idx = coordinator.tabs.firstIndex(where: { $0.id == tab.id }) {
                    coordinator.tabs[idx].isPinned.toggle()
                    coordinator.saveTabs()
                }
            }) {
                Label(tab.isPinned ? "Desfijar Pestaña" : "Fijar Pestaña", systemImage: "pin")
            }

            Menu("Mover a Espacio") {
                ForEach(coordinator.spaces.filter { $0.id != tab.spaceID }) { targetSpace in
                    Button(targetSpace.name) {
                        if let idx = coordinator.tabs.firstIndex(where: { $0.id == tab.id }) {
                            coordinator.tabs[idx].spaceID = targetSpace.id
                            coordinator.saveTabs()
                        }
                    }
                }
            }

            Button(role: .destructive, action: {
                coordinator.closeTab(id: tab.id)
            }) {
                Label("Cerrar Pestaña", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var bottomBarActions: some View {
        HStack {
            Text("\(filteredTabs.count) abiertas")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))

            Spacer()

            Button(action: {
                _ = coordinator.createNewTab(in: coordinator.activeSpaceID)
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    LiquidIconView(.newTab, size: 14)
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
}
