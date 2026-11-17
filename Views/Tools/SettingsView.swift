import SwiftUI

// MARK: - SettingsView (Comprehensive Settings & Factory Reset Zone)

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

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                List {
                    // SECCIÓN 1: IDIOMA
                    Section(Loc.tr("settings_language")) {
                        ForEach(AppLanguage.allCases) { lang in
                            Button {
                                HapticManager.shared.touchSelection()
                                locManager.currentLanguage = lang
                            } label: {
                                HStack {
                                    Text(lang.flagSymbol)
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .frame(width: 30, height: 30)
                                        .background(theme.surfaceElevated(for: scheme))
                                        .clipShape(Circle())
                                        .foregroundStyle(theme.textPrimary(for: scheme))

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
                    }

                    // SECCIÓN 2: APARIENCIA Y CRISTAL LÍQUIDO
                    Section(Loc.tr("settings_theme")) {
                        Picker("Modo Visual", selection: $themeManager.currentMode) {
                            Text(Loc.tr("onboarding_theme_light")).tag(AppThemeMode.light)
                            Text(Loc.tr("onboarding_theme_dark")).tag(AppThemeMode.dark)
                            Text(Loc.tr("onboarding_theme_system")).tag(AppThemeMode.system)
                        }
                        .pickerStyle(.inline)
                    }

                    // SECCIÓN 3: MOTOR DE BÚSQUEDA
                    Section(Loc.tr("settings_search_engine")) {
                        ForEach(SearchEngineType.allCases) { engine in
                            Button {
                                HapticManager.shared.touchSelection()
                                selectedEngineRaw = engine.rawValue
                                UserDefaults.standard.set(engine.rawValue, forKey: "smartbot_default_search_engine")
                            } label: {
                                HStack(spacing: 12) {
                                    BrandLogoView(engine: engine, style: .fullColor, size: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(engine.displayName)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(theme.textPrimary(for: scheme))

                                        Text(engine.searchDescription)
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

                    // SECCIÓN 4: SEGURIDAD Y HERRAMIENTAS
                    Section(Loc.tr("settings_security")) {
                        Toggle("Bloqueo de Aplicación al Salir", isOn: Binding(
                            get: { KeychainVault.shared.isAppLockEnabled },
                            set: { KeychainVault.shared.isAppLockEnabled = $0 }
                        ))
                        .tint(theme.textPrimary(for: scheme))

                        if KeychainVault.shared.canUseBiometrics {
                            let bioType = KeychainVault.shared.biometricType
                            Toggle(bioType == .faceID ? "Usar Face ID" : "Usar Touch ID", isOn: Binding(
                                get: { KeychainVault.shared.isBiometricAuthEnabled },
                                set: { KeychainVault.shared.isBiometricAuthEnabled = $0 }
                            ))
                            .tint(theme.textPrimary(for: scheme))
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
                    }

                    // SECCIÓN 5: CRÉDITOS Y ACERCA DE
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
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                }
                                Spacer()
                                LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme))
                            }
                        }
                    }

                    // SECCIÓN 6: ZONA DE RESTABLECIMIENTO (RESET DE FÁBRICA)
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
        }
    }
}
