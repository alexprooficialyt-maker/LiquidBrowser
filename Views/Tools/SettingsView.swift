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
    @State private var isShowingPinSetupSheet: Bool = false
    @State private var isShowingFactoryResetAlert: Bool = false
    @State private var isShowingCacheClearedAlert: Bool = false
    @State private var isShowingBiometricsErrorAlert: Bool = false
    @State private var biometricsErrorMessage: String = ""

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
            .sheet(isPresented: $isShowingPinSetupSheet) {
                PinSetupSheet()
            }
            .alert("Seguridad Biométrica", isPresented: $isShowingBiometricsErrorAlert) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(biometricsErrorMessage)
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

    // MARK: - 4. Sección de Seguridad (Conmutadores Verdes Apple & Selector Independiente)

    @ViewBuilder
    private func securitySection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        Section(Loc.tr("settings_security")) {
            // 1. Configurar / Cambiar PIN de 4 Dígitos
            Button {
                HapticManager.shared.touchLight()
                isShowingPinSetupSheet = true
            } label: {
                HStack(spacing: 12) {
                    LiquidIconView(.pinPad, size: 16, color: theme.textPrimary(for: scheme))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(KeychainVault.shared.hasAppPIN() ? "Cambiar PIN de 4 Dígitos" : "Configurar PIN de 4 Dígitos")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        Text(KeychainVault.shared.hasAppPIN() ? "PIN activo y protegido en Secure Enclave" : "Protección adicional con código manual")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(theme.textSecondary(for: scheme))
                    }

                    Spacer()

                    Text(KeychainVault.shared.hasAppPIN() ? "Configurado" : "Inactivo")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(KeychainVault.shared.hasAppPIN() ? appleGreen : theme.textSecondary(for: scheme))

                    LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme))
                }
            }

            // 2. Activar Face ID / Touch ID (Protegido con canEvaluatePolicy y tryEnableBiometrics)
            if KeychainVault.shared.canUseBiometrics {
                let bioType = KeychainVault.shared.biometricType
                let bioName = bioType == .faceID ? "Usar Face ID" : (bioType == .touchID ? "Usar Touch ID" : "Usar Biometría")

                Toggle(bioName, isOn: Binding(
                    get: { KeychainVault.shared.isBiometricAuthEnabled },
                    set: { newValue in
                        if newValue {
                            HapticManager.shared.touchSelection()
                            Task {
                                let (success, err) = await DeviceBiometryHelper.shared.tryEnableBiometrics()
                                if success {
                                    KeychainVault.shared.isBiometricAuthEnabled = true
                                    KeychainVault.shared.isAppLockEnabled = true
                                } else {
                                    await MainActor.run {
                                        KeychainVault.shared.isBiometricAuthEnabled = false
                                        if let err = err {
                                            biometricsErrorMessage = err
                                            isShowingBiometricsErrorAlert = true
                                        }
                                    }
                                }
                            }
                        } else {
                            KeychainVault.shared.isBiometricAuthEnabled = false
                        }
                    }
                ))
                .tint(appleGreen)
            }

            // 3. Bloqueo Automático al Salir de la App
            Toggle("Bloqueo automático al salir", isOn: Binding(
                get: { KeychainVault.shared.isAppLockEnabled },
                set: { KeychainVault.shared.isAppLockEnabled = $0 }
            ))
            .tint(appleGreen)

            // Bóveda de Contraseñas
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

            // Privacidad y Anti-Espías
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

// MARK: - PinSetupSheet (Handcrafted Apple Liquid Glass PIN Creator & Confirmer)

public struct PinSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirming: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isShaking: Bool = false

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(theme.surfaceElevated(for: scheme))
                            .frame(width: 72, height: 72)
                            .overlay {
                                Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                            }
                        LiquidIconView(.pinPad, size: 32, color: theme.textPrimary(for: scheme))
                    }

                    VStack(spacing: 6) {
                        Text(isConfirming ? "Confirma tu PIN" : "Crea tu PIN de 4 dígitos")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        Text(isConfirming ? "Introduce el mismo código para verificarlo" : "Este PIN se usará para proteger la app y tus perfiles")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(theme.textSecondary(for: scheme))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // 4 Puntos de Estado
                    HStack(spacing: 16) {
                        let currentDigits = isConfirming ? confirmPin : pin
                        ForEach(0..<4, id: \.self) { idx in
                            Circle()
                                .fill(idx < currentDigits.count ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.18))
                                .frame(width: 14, height: 14)
                                .overlay {
                                    Circle().strokeBorder(theme.specularBorder(for: scheme), lineWidth: 0.5)
                                }
                        }
                    }
                    .modifier(ShakeEffect(shakes: isShaking ? 3 : 0))
                    .padding(.vertical, 8)

                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.red)
                    } else {
                        Text(" ").font(.system(size: 13))
                    }

                    numericPad(theme: theme, scheme: scheme)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Seguridad PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
                if KeychainVault.shared.hasAppPIN() {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Eliminar PIN") {
                            KeychainVault.shared.deleteAppPIN()
                            HapticManager.shared.notifyWarning()
                            dismiss()
                        }
                        .foregroundStyle(Color.red)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func numericPad(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let keys = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "delete"]
        ]

        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Color.clear.frame(width: 68, height: 68)
                        } else if key == "delete" {
                            Button {
                                HapticManager.shared.touchLight()
                                if isConfirming {
                                    if !confirmPin.isEmpty { confirmPin.removeLast() }
                                } else {
                                    if !pin.isEmpty { pin.removeLast() }
                                }
                                errorMessage = nil
                            } label: {
                                LiquidIconView(.close, size: 20, color: theme.textPrimary(for: scheme))
                                    .frame(width: 68, height: 68)
                                    .background(theme.surfaceElevated(for: scheme).opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                HapticManager.shared.touchSelection()
                                handleKey(key)
                            } label: {
                                Text(key)
                                    .font(.system(size: 26, weight: .light, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))
                                    .frame(width: 68, height: 68)
                                    .background(theme.surfaceElevated(for: scheme))
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func handleKey(_ digit: String) {
        if !isConfirming {
            guard pin.count < 4 else { return }
            pin.append(digit)
            if pin.count == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(LiquidAnimation.smoothSpring) {
                        isConfirming = true
                    }
                }
            }
        } else {
            guard confirmPin.count < 4 else { return }
            confirmPin.append(digit)
            if confirmPin.count == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if confirmPin == pin {
                        KeychainVault.shared.saveAppPIN(pin)
                        KeychainVault.shared.isAppLockEnabled = true
                        HapticManager.shared.notifySuccess()
                        dismiss()
                    } else {
                        HapticManager.shared.notifyError()
                        errorMessage = "Los códigos PIN no coinciden. Inténtalo de nuevo."
                        isShaking = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            isShaking = false
                            confirmPin = ""
                        }
                    }
                }
            }
        }
    }
}
