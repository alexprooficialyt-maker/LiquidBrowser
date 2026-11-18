import SwiftUI

// MARK: - SettingsView (Comprehensive Settings, Green Apple Toggles & Factory Reset Zone)

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var themeManager = ThemeManager.shared
    @State private var locManager = LocalizationManager.shared
    @State private var storage = StorageEngine.shared
    @State private var selectedEngineRaw: String = UserDefaults.standard.string(forKey: "smartbot_default_search_engine") ?? SearchEngineType.google.rawValue

    // Sub-hojas
    @State private var isShowingPasswordVault: Bool = false
    @State private var isShowingAntiSpyDashboard: Bool = false
    @State private var isShowingCredits: Bool = false
    @State private var isShowingFactoryResetAlert: Bool = false
    @State private var isShowingCacheClearedAlert: Bool = false

    private var appleGreen: Color {
        themeManager.appleGreen
    }

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                List {
                    languageSection(theme: theme, scheme: scheme)
                    appearanceSection()
                    searchEngineSection(theme: theme, scheme: scheme)
                    securitySection(theme: theme, scheme: scheme)
                    creditsSection(theme: theme, scheme: scheme)
                    resetSection(theme: theme, scheme: scheme)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Loc.tr("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
            .sheet(isPresented: $isShowingPasswordVault) {
                PasswordVaultView()
            }
            .sheet(isPresented: $isShowingAntiSpyDashboard) {
                AntiSpyPrivacyDashboardView()
            }
            .sheet(isPresented: $isShowingCredits) {
                CreditsView()
            }
            .alert(Loc.tr("settings_factory_reset"), isPresented: $isShowingFactoryResetAlert) {
                Button(Loc.tr("settings_factory_reset_confirm"), role: .destructive) {
                    storage.factoryResetAllData()
                    dismiss()
                }
                Button(Loc.tr("cancel"), role: .cancel) {}
            } message: {
                Text(Loc.tr("settings_factory_reset_warning"))
            }
            .alert("Caché Vaciada", isPresented: $isShowingCacheClearedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Se han eliminado los datos temporales y favicons descargados correctamente.")
            }
        }
    }

    // MARK: - 1. Sección de Idiomas (15 Idiomas con Banderas Oficiales)

    @ViewBuilder
    private func languageSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_language")) {
            ForEach(AppLanguage.allCases) { lang in
                languageRow(lang: lang, theme: theme, scheme: scheme)
            }
        }
    }

    @ViewBuilder
    private func languageRow(lang: AppLanguage, theme: ThemeManager, scheme: ColorScheme) -> some View {
        Button {
            HapticManager.shared.touchSelection()
            locManager.currentLanguage = lang
        } label: {
            HStack(spacing: 12) {
                LanguageFlagView(language: lang, size: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(lang.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(lang.localizedName)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }

                Spacer()

                if locManager.currentLanguage == lang {
                    LiquidIconView(.checkmark, size: 14, color: theme.textPrimary(for: scheme))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 2. Sección de Apariencia

    @ViewBuilder
    private func appearanceSection() -> some View {
        Section(Loc.tr("settings_theme")) {
            Picker("Modo Visual", selection: $themeManager.currentMode) {
                Text(Loc.tr("onboarding_theme_light")).tag(AppThemeMode.light)
                Text(Loc.tr("onboarding_theme_dark")).tag(AppThemeMode.dark)
                Text(Loc.tr("onboarding_theme_system")).tag(AppThemeMode.system)
            }
            .pickerStyle(.inline)
        }
    }

    // MARK: - 3. Sección de Motores de Búsqueda (8 Motores)

    @ViewBuilder
    private func searchEngineSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_search_engine")) {
            ForEach(SearchEngineType.allCases) { engine in
                Button {
                    HapticManager.shared.touchSelection()
                    selectedEngineRaw = engine.rawValue
                    UserDefaults.standard.set(engine.rawValue, forKey: "smartbot_default_search_engine")
                } label: {
                    HStack(spacing: 12) {
                        SearchEngineLogoView(engine: engine, size: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(engine.displayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))

                            Text(engineSubtitle(engine))
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                                .lineLimit(1)
                        }

                        Spacer()

                        if selectedEngineRaw == engine.rawValue {
                            LiquidIconView(.checkmark, size: 14, color: theme.textPrimary(for: scheme))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 4. Sección de Seguridad (Conmutadores Verdes Apple)

    @ViewBuilder
    private func securitySection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_security")) {
            Toggle("Bloqueo de Aplicación al Salir", isOn: Binding(
                get: { KeychainVault.shared.isAppLockEnabled },
                set: { KeychainVault.shared.isAppLockEnabled = $0 }
            ))
            .tint(appleGreen)

            if KeychainVault.shared.canUseBiometrics {
                let bioType = KeychainVault.shared.biometricType
                Toggle(bioType == .faceID ? "Usar Face ID" : "Usar Touch ID", isOn: Binding(
                    get: { KeychainVault.shared.isBiometricAuthEnabled },
                    set: { KeychainVault.shared.isBiometricAuthEnabled = $0 }
                ))
                .tint(appleGreen)
            }

            Button {
                isShowingPasswordVault = true
            } label: {
                HStack {
                    LiquidIconView(.keyPassword, size: 16, color: theme.textPrimary(for: scheme))
                    Text(Loc.tr("settings_passwords"))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                    Spacer()
                    LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme))
                }
            }

            Button {
                isShowingAntiSpyDashboard = true
            } label: {
                HStack {
                    LiquidIconView(.shieldActive, size: 16, color: theme.textPrimary(for: scheme))
                    Text(Loc.tr("settings_privacy"))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                    Spacer()
                    LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme))
                }
            }

            // Limpiar Caché y Favicons
            Button {
                HapticManager.shared.touchMedium()
                FaviconFetcherService.shared.clearFaviconCache()
                isShowingCacheClearedAlert = true
            } label: {
                HStack {
                    LiquidIconView(.renewTab, size: 16, color: theme.textPrimary(for: scheme))
                    Text("Vaciar Caché y Favicons")
                        .foregroundStyle(theme.textPrimary(for: scheme))
                    Spacer()
                }
            }
        }
    }

    // MARK: - 5. Sección de Créditos y Autoría Oficial

    @ViewBuilder
    private func creditsSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_credits")) {
            Button {
                isShowingCredits = true
            } label: {
                HStack {
                    LiquidIconView(.userProfile, size: 16, color: theme.textPrimary(for: scheme))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SmartBot Browser")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        Text("Hecho por Rubén Aguilarte")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }
                    Spacer()
                    LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme))
                }
            }
        }
    }

    // MARK: - 6. Zona de Restablecimiento

    @ViewBuilder
    private func resetSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_reset_zone")) {
            VStack(alignment: .leading, spacing: 10) {
                Text(Loc.tr("settings_factory_reset_warning"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(theme.textSecondary(for: scheme))
                    .lineSpacing(2)

                Button(role: .destructive) {
                    HapticManager.shared.notifyWarning()
                    isShowingFactoryResetAlert = true
                } label: {
                    HStack {
                        LiquidIconView(.trash, size: 16, color: Color.red)
                        Text(Loc.tr("settings_factory_reset"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.red)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func engineSubtitle(_ engine: SearchEngineType) -> String {
        switch engine {
        case .google: return "Resultados web globales y completos"
        case .duckDuckGo: return "Privacidad estricta sin rastreo publicitario"
        case .brave: return "Búsqueda independiente y segura"
        case .ecosia: return "Financia la plantación de árboles"
        case .bing: return "Motor inteligente de Microsoft"
        case .startpage: return "Resultados de Google con privacidad total"
        case .qwant: return "Buscador europeo que protege tus datos"
        case .perplexity: return "Búsqueda conversacional guiada por IA"
        }
    }
}
