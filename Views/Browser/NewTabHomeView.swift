import SwiftUI

// MARK: - NewTabHomeView (Liquid Glass Monocromo con Saludo y Accesos)

public struct NewTabHomeView: View {
    @Bindable var coordinator: WebEngineCoordinator
    @State private var searchText: String = ""
    @AppStorage("userName") private var userName = ""
    @AppStorage("searchEngine") private var searchEngine = "Google"

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isSearchFocused: Bool

    public init(coordinator: WebEngineCoordinator) {
        self.coordinator = coordinator
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let prefix: String
        if hour < 12 {
            prefix = "Buenos días"
        } else if hour < 20 {
            prefix = "Buenas tardes"
        } else {
            prefix = "Buenas noches"
        }
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? prefix : "\(prefix), \(name)"
    }

    private var activeEngineIcon: LiquidIconType {
        switch searchEngine {
        case "DuckDuckGo": return .duckDuckGoSearch
        case "Brave":      return .braveSearch
        case "Ecosia":     return .ecosiaSearch
        default:           return .googleSearch
        }
    }

    private let quickShortcuts: [(name: String, url: String, icon: LiquidIconType)] = [
        ("Google", "https://www.google.com", .googleSearch),
        ("YouTube", "https://www.youtube.com", .desktopMode),
        ("Wikipedia", "https://es.wikipedia.org", .readerMode),
        ("GitHub", "https://github.com", .spaceCode)
    ]

    public var body: some View {
        let theme = ThemeManager.shared

        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // Cabecera superior con saludo y estado de Cuenta de Google
                headerBar(theme: theme)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                Spacer(minLength: 10)

                // Barra de Búsqueda Central en Cristal Líquido
                centerSearchBar(theme: theme)
                    .padding(.horizontal, 20)

                // Accesos Directos Monocromos
                shortcutsGrid(theme: theme)
                    .padding(.horizontal, 24)

                // Espacios Activos Resumen
                spacesQuickBar(theme: theme)
                    .padding(.horizontal, 24)

                Spacer(minLength: 80)
            }
        }
    }

    // MARK: - Header Bar

    @ViewBuilder
    private func headerBar(theme: ThemeManager) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                Text("Explora la web con LiquidBrowser")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
            }

            Spacer()

            // Cuenta de Google Badge
            let googleState = GoogleAuthManager.shared.accountState
            Button(action: {
                HapticManager.shared.touchLight()
                if !googleState.isSignedIn {
                    coordinator.loadURL(GoogleAuthManager.shared.googleSignInURL)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(theme.cardBackground(for: colorScheme))
                        .frame(width: 42, height: 42)
                        .overlay {
                            Circle().strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                        }

                    if googleState.isSignedIn {
                        Text(googleState.initials)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                    } else {
                        LiquidIconView(.googleAccount, size: 20, color: theme.textSecondary(for: colorScheme))
                    }
                }
            }
            .pressableFeedback()
        }
    }

    // MARK: - Search Bar

    @ViewBuilder
    private func centerSearchBar(theme: ThemeManager) -> some View {
        HStack(spacing: 12) {
            LiquidIconView(activeEngineIcon, size: 22, color: theme.textPrimary(for: colorScheme))

            TextField("Buscar o ingresar URL...", text: $searchText)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))
                .focused($isSearchFocused)
                .submitLabel(.go)
                .onSubmit {
                    submitSearch()
                }

            if !searchText.isEmpty {
                Button(action: {
                    HapticManager.shared.touchLight()
                    searchText = ""
                }) {
                    LiquidIconView(.close, size: 14, color: theme.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .liquidGlass(config: .card)
    }

    // MARK: - Shortcuts Grid

    @ViewBuilder
    private func shortcutsGrid(theme: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accesos Frecuentes")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))

            HStack(spacing: 14) {
                ForEach(quickShortcuts, id: \.name) { shortcut in
                    Button(action: {
                        HapticManager.shared.touchMedium()
                        if let url = URL(string: shortcut.url) {
                            coordinator.loadURL(url)
                        }
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(theme.cardBackground(for: colorScheme))
                                    .frame(width: 58, height: 58)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                                    }

                                LiquidIconView(shortcut.icon, size: 24, color: theme.textPrimary(for: colorScheme))
                            }

                            Text(shortcut.name)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }
                    }
                    .pressableFeedback()
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Spaces Quick Bar

    @ViewBuilder
    private func spacesQuickBar(theme: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Espacios de Navegación")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(coordinator.spaces) { space in
                        let isSelected = (coordinator.activeSpaceID == space.id)
                        let icon = LiquidIconType(rawValue: space.iconTypeRaw) ?? .spaceFolder

                        Button(action: {
                            HapticManager.shared.selectionChanged()
                            coordinator.activeSpaceID = space.id
                        }) {
                            HStack(spacing: 8) {
                                LiquidIconView(icon, size: 14, color: isSelected ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme))
                                Text(space.name)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? (colorScheme == .dark ? Color.white : Color.black) : theme.cardBackground(for: colorScheme))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                            }
                        }
                        .pressableFeedback()
                    }
                }
            }
        }
    }

    private func submitSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        HapticManager.shared.touchMedium()
        isSearchFocused = false
        coordinator.navigate(to: query)
    }
}
