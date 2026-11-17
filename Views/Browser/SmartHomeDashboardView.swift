import SwiftUI

// MARK: - SmartHomeDashboardView (Personalized Home with Greeting, Searches & Saved Sites)

public struct SmartHomeDashboardView: View {
    @Environment(\.colorScheme) private var systemColorScheme

    public var onSelectQuery: (String) -> Void
    public var onSelectURL: (URL) -> Void
    public var onOpenProfileSwitcher: () -> Void

    @State private var storage = StorageEngine.shared
    @State private var isAddingSite: Bool = false
    @State private var newSiteTitle: String = ""
    @State private var newSiteURL: String = ""

    public init(
        onSelectQuery: @escaping (String) -> Void,
        onSelectURL: @escaping (URL) -> Void,
        onOpenProfileSwitcher: @escaping () -> Void
    ) {
        self.onSelectQuery = onSelectQuery
        self.onSelectURL = onSelectURL
        self.onOpenProfileSwitcher = onOpenProfileSwitcher
    }

    private var smartGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = storage.activeProfile.name
        if hour >= 5 && hour < 12 {
            return String(format: Loc.tr("home_greeting_morning"), name)
        } else if hour >= 12 && hour < 20 {
            return String(format: Loc.tr("home_greeting_afternoon"), name)
        } else {
            return String(format: Loc.tr("home_greeting_evening"), name)
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let activeProfile = storage.activeProfile
        let recentSearches = storage.recentSearches(limit: 8)
        let savedSites = storage.savedSitesForActiveProfile()

        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // 1. Barra de Perfil Superior & Saludo
                headerProfileBar(profile: activeProfile, theme: theme, scheme: scheme)
                    .padding(.top, 16)

                // 2. Búsquedas Recientes
                recentSearchesSection(searches: recentSearches, theme: theme, scheme: scheme)

                // 3. Páginas Guardadas Abajo (Favoritos Editables)
                savedSitesSection(sites: savedSites, theme: theme, scheme: scheme)

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $isAddingSite) {
            addSiteSheet(theme: theme, scheme: scheme)
        }
    }

    // MARK: - 1. Cabecera con Perfil y Saludo Inteligente

    @ViewBuilder
    private func headerProfileBar(profile: UserProfile, theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    HapticManager.shared.touchLight()
                    onOpenProfileSwitcher()
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(profile.accentColor.swatchColor)
                            .frame(width: 10, height: 10)

                        Text(profile.name)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        LiquidIconView(.chevronRight, size: 10, color: theme.textSecondary(for: scheme))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.surfaceElevated(for: scheme))
                    .clipShape(Capsule())
                    .overlay {
                        Capsule().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text(smartGreeting)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2. Búsquedas Recientes

    @ViewBuilder
    private func recentSearchesSection(searches: [SearchRecord], theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Loc.tr("home_recent_searches"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: scheme))

                Spacer()

                if !searches.isEmpty {
                    Button(Loc.tr("home_clear_searches")) {
                        HapticManager.shared.touchLight()
                        storage.clearSearches()
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(theme.textSecondary(for: scheme))
                }
            }

            if searches.isEmpty {
                HStack {
                    Text(Loc.tr("home_no_searches"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                    Spacer()
                }
                .padding(14)
                .liquidGlassCard(cornerRadius: 14)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(searches) { record in
                            Button {
                                HapticManager.shared.touchLight()
                                onSelectQuery(record.query)
                            } label: {
                                HStack(spacing: 8) {
                                    BrandLogoView(engine: record.engine, style: .monochrome, size: 14)

                                    Text(record.query)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(theme.surfaceElevated(for: scheme))
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                                }
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    storage.deleteSearchRecord(id: record.id)
                                } label: {
                                    Label(Loc.tr("delete"), systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 3. Páginas Guardadas Abajo (Favoritos Editables)

    @ViewBuilder
    private func savedSitesSection(sites: [SavedSite], theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Loc.tr("home_saved_sites"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: scheme))

                Spacer()

                Button {
                    HapticManager.shared.touchLight()
                    isAddingSite = true
                } label: {
                    HStack(spacing: 4) {
                        LiquidIconView(.newTab, size: 12, color: theme.textPrimary(for: scheme))
                        Text("Añadir")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 78), spacing: 16)], spacing: 16) {
                ForEach(sites) { site in
                    Button {
                        HapticManager.shared.touchLight()
                        onSelectURL(site.url)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(theme.surfaceElevated(for: scheme))
                                    .frame(width: 58, height: 58)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                                    }

                                Text(String(site.title.prefix(1)).uppercased())
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))
                            }

                            Text(site.title)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(width: 74)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            storage.deleteSavedSite(id: site.id)
                        } label: {
                            Label(Loc.tr("delete"), systemImage: "trash")
                        }
                    }
                }

                // Botón Añadir Página
                Button {
                    HapticManager.shared.touchLight()
                    isAddingSite = true
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(theme.textSecondary(for: scheme).opacity(0.5))
                                .frame(width: 58, height: 58)

                            LiquidIconView(.newTab, size: 20, color: theme.textSecondary(for: scheme))
                        }

                        Text("Añadir")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(theme.textSecondary(for: scheme))
                    }
                    .frame(width: 74)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 20)
        }
    }

    // MARK: - Sheet para Añadir Sitio Favorito

    @ViewBuilder
    private func addSiteSheet(theme: ThemeManager, scheme: ColorScheme) -> some View {
        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre del Sitio")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField("Ej. Apple", text: $newSiteTitle)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("URL del Sitio")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField("https://ejemplo.com", text: $newSiteURL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(Loc.tr("home_add_saved_site"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("cancel")) { isAddingSite = false }
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("save")) {
                        saveNewSite()
                    }
                    .disabled(newSiteTitle.isEmpty || newSiteURL.isEmpty)
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    private func saveNewSite() {
        var formatted = newSiteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formatted.hasPrefix("http://") && !formatted.hasPrefix("https://") {
            formatted = "https://\(formatted)"
        }
        if let url = URL(string: formatted) {
            storage.addSavedSite(title: newSiteTitle, url: url)
            newSiteTitle = ""
            newSiteURL = ""
            isAddingSite = false
            HapticManager.shared.notifySuccess()
        }
    }
}
