import SwiftUI
import LocalAuthentication

// MARK: - OnboardingFlowView (5-Step Apple Liquid Glass Sequence)

public struct OnboardingFlowView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    public var onFinished: () -> Void

    @State private var currentStep: Int = 1
    private let totalSteps: Int = 5

    // Paso 1: Idioma
    @State private var selectedLanguage: AppLanguage = LocalizationManager.shared.currentLanguage

    // Paso 2: Perfil Inicial
    @State private var userName: String = ""
    @State private var userAgeText: String = ""
    @State private var selectedColor: ProfileAccentColor = .monochrome
    @State private var profileDescription: String = ""

    // Paso 3: Apariencia
    @State private var selectedTheme: AppThemeMode = ThemeManager.shared.currentMode

    // Paso 4: Buscador
    @State private var selectedEngine: SearchEngineType = .google

    // Paso 5: Seguridad
    @State private var isBiometricsEnabled: Bool = false
    @State private var isPinSetupActive: Bool = false
    @State private var pinInput: String = ""
    @State private var pinConfirmInput: String = ""
    @State private var isConfirmingPin: Bool = false
    @State private var pinErrorMessage: String? = nil

    // Estado Cinemático Final
    @State private var isShowingCinematicWelcome: Bool = false

    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let effectiveScheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        ZStack {
            // Fondo Líquido Monocromo
            theme.background(for: effectiveScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra de Progreso Superior Apple
                HStack(spacing: 6) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? theme.textPrimary(for: effectiveScheme) : theme.textPrimary(for: effectiveScheme).opacity(0.15))
                            .frame(height: 3)
                            .animation(LiquidAnimation.interactiveSpring, value: currentStep)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Contenido del Paso Activo
                TabView(selection: $currentStep) {
                    step1LanguageView(theme: theme, scheme: effectiveScheme).tag(1)
                    step2ProfileView(theme: theme, scheme: effectiveScheme).tag(2)
                    step3AppearanceView(theme: theme, scheme: effectiveScheme).tag(3)
                    step4SearchEngineView(theme: theme, scheme: effectiveScheme).tag(4)
                    step5SecurityView(theme: theme, scheme: effectiveScheme).tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(LiquidAnimation.smoothSpring, value: currentStep)

                // Botón de Continuar Fijo Inferior
                bottomNavigationControls(theme: theme, scheme: effectiveScheme)
            }
        }
        .fullScreenCover(isPresented: $isShowingCinematicWelcome) {
            WelcomeLetterAnimationView(
                userName: userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "SmartBot" : userName,
                onComplete: {
                    StorageEngine.shared.hasCompletedOnboarding = true
                    onFinished()
                }
            )
        }
    }

    // MARK: - Paso 1: Idioma

    @ViewBuilder
    private func step1LanguageView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.globeLanguage, size: 44, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step1_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step1_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            HapticManager.shared.touchSelection()
                            selectedLanguage = lang
                            LocalizationManager.shared.currentLanguage = lang
                        } label: {
                            HStack(spacing: 16) {
                                Text(lang.flagSymbol)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .frame(width: 34, height: 34)
                                    .background(theme.surfaceElevated(for: scheme))
                                    .clipShape(Circle())
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))

                                    Text(lang.localizedName)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                }

                                Spacer()

                                if selectedLanguage == lang {
                                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .liquidGlassCard(cornerRadius: 16)
                            .overlay {
                                if selectedLanguage == lang {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 1.5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }

    // MARK: - Paso 2: Perfil Inicial

    @ViewBuilder
    private func step2ProfileView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.userProfile, size: 44, color: selectedColor.color(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step2_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step2_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Nombre
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Loc.tr("onboarding_step2_name_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField(Loc.tr("onboarding_step2_name_placeholder"), text: $userName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    // Edad
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Loc.tr("onboarding_step2_age_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField(Loc.tr("onboarding_step2_age_placeholder"), text: $userAgeText)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    // Selector de Color
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Loc.tr("onboarding_step2_color_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ProfileAccentColor.allCases) { color in
                                    Circle()
                                        .fill(color.swatchColor)
                                        .frame(width: 32, height: 32)
                                        .overlay {
                                            if selectedColor == color {
                                                Circle()
                                                    .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 2)
                                                    .padding(-4)
                                            }
                                        }
                                        .onTapGesture {
                                            HapticManager.shared.touchSelection()
                                            selectedColor = color
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }

                    // Descripción
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Loc.tr("onboarding_step2_desc_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField(Loc.tr("onboarding_step2_desc_placeholder"), text: $profileDescription)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Paso 3: Apariencia

    @ViewBuilder
    private func step3AppearanceView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.palette, size: 44, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step3_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step3_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 14) {
                    themeOptionCard(
                        mode: .light,
                        title: Loc.tr("onboarding_theme_light"),
                        desc: Loc.tr("onboarding_theme_light_desc"),
                        theme: theme,
                        scheme: scheme
                    )

                    themeOptionCard(
                        mode: .dark,
                        title: Loc.tr("onboarding_theme_dark"),
                        desc: Loc.tr("onboarding_theme_dark_desc"),
                        theme: theme,
                        scheme: scheme
                    )

                    themeOptionCard(
                        mode: .system,
                        title: Loc.tr("onboarding_theme_system"),
                        desc: Loc.tr("onboarding_theme_system_desc"),
                        theme: theme,
                        scheme: scheme
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func themeOptionCard(mode: AppThemeMode, title: String, desc: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        Button {
            HapticManager.shared.touchSelection()
            selectedTheme = mode
            ThemeManager.shared.currentMode = mode
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(mode == .light ? Color.white : (mode == .dark ? Color.black : Color.gray))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Circle().strokeBorder(theme.textPrimary(for: scheme).opacity(0.3), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(desc)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }

                Spacer()

                if selectedTheme == mode {
                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .liquidGlassCard(cornerRadius: 18)
            .overlay {
                if selectedTheme == mode {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Paso 4: Buscador

    @ViewBuilder
    private func step4SearchEngineView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.search, size: 44, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step4_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step4_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    ForEach(SearchEngineType.allCases) { engine in
                        Button {
                            HapticManager.shared.touchSelection()
                            selectedEngine = engine
                            UserDefaults.standard.set(engine.rawValue, forKey: "smartbot_default_search_engine")
                        } label: {
                            HStack(spacing: 16) {
                                BrandLogoView(engine: engine, style: .fullColor, size: 30)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(engine.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))

                                    Text(engine.searchDescription)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                        .lineLimit(2)
                                }

                                Spacer()

                                if selectedEngine == engine {
                                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .liquidGlassCard(cornerRadius: 16)
                            .overlay {
                                if selectedEngine == engine {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 1.5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Paso 5: Seguridad y Bloqueo

    @ViewBuilder
    private func step5SecurityView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                let bioType = KeychainVault.shared.biometricType
                LiquidIconView(bioType == .faceID ? .faceID : .touchID, size: 48, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step5_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step5_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 14) {
                    // Biometría (si está disponible)
                    if KeychainVault.shared.canUseBiometrics {
                        HStack(spacing: 16) {
                            LiquidIconView(bioType == .faceID ? .faceID : .touchID, size: 24, color: theme.textPrimary(for: scheme))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bioType == .faceID ? "Activar Face ID" : "Activar Touch ID")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Text("Desbloqueo ultrarrápido al abrir la app")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }

                            Spacer()

                            Toggle("", isOn: $isBiometricsEnabled)
                                .labelsHidden()
                                .tint(theme.textPrimary(for: scheme))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassCard(cornerRadius: 16)
                    }

                    // Configurar PIN de 4 dígitos
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            LiquidIconView(.pinPad, size: 22, color: theme.textPrimary(for: scheme))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(Loc.tr("onboarding_security_pin_enable"))
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Text(isPinSetupActive ? "Introduce 4 dígitos numéricos" : "Código de respaldo")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }

                            Spacer()

                            Toggle("", isOn: $isPinSetupActive)
                                .labelsHidden()
                                .tint(theme.textPrimary(for: scheme))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassCard(cornerRadius: 16)

                        if isPinSetupActive {
                            pinEntryInline(theme: theme, scheme: scheme)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // Teclado PIN en línea para configuración
    @ViewBuilder
    private func pinEntryInline(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            Text(isConfirmingPin ? "Confirma tu PIN de 4 dígitos" : "Introduce tu PIN de 4 dígitos")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondary(for: scheme))

            // 4 Puntos de estado
            HStack(spacing: 16) {
                let current = isConfirmingPin ? pinConfirmInput : pinInput
                ForEach(0..<4, id: \.self) { idx in
                    Circle()
                        .fill(idx < current.count ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.15))
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.vertical, 6)

            if let err = pinErrorMessage {
                Text(err)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.red)
            }

            // Teclado numérico 3x4
            let keys = [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                ["", "0", "delete"]
            ]

            VStack(spacing: 10) {
                ForEach(keys, id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(row, id: \.self) { key in
                            if key.isEmpty {
                                Color.clear.frame(width: 60, height: 50)
                            } else if key == "delete" {
                                Button {
                                    HapticManager.shared.touchLight()
                                    if isConfirmingPin {
                                        if !pinConfirmInput.isEmpty { pinConfirmInput.removeLast() }
                                    } else {
                                        if !pinInput.isEmpty { pinInput.removeLast() }
                                    }
                                } label: {
                                    LiquidIconView(.close, size: 18, color: theme.textPrimary(for: scheme))
                                        .frame(width: 60, height: 50)
                                        .background(theme.surfaceElevated(for: scheme))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button {
                                    HapticManager.shared.touchSelection()
                                    handlePinDigit(key)
                                } label: {
                                    Text(key)
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))
                                        .frame(width: 60, height: 50)
                                        .background(theme.surfaceElevated(for: scheme))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .liquidGlassCard(cornerRadius: 18)
    }

    private func handlePinDigit(_ digit: String) {
        if !isConfirmingPin {
            if pinInput.count < 4 {
                pinInput.append(digit)
                if pinInput.count == 4 {
                    // Pasar a confirmación
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isConfirmingPin = true
                    }
                }
            }
        } else {
            if pinConfirmInput.count < 4 {
                pinConfirmInput.append(digit)
                if pinConfirmInput.count == 4 {
                    if pinInput == pinConfirmInput {
                        HapticManager.shared.notifySuccess()
                        pinErrorMessage = nil
                    } else {
                        HapticManager.shared.notifyError()
                        pinErrorMessage = "Los PIN no coinciden. Vuelve a empezar."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            pinInput = ""
                            pinConfirmInput = ""
                            isConfirmingPin = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Botón Inferior de Navegación

    @ViewBuilder
    private func bottomNavigationControls(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            Button {
                HapticManager.shared.touchMedium()
                if currentStep < totalSteps {
                    withAnimation(LiquidAnimation.smoothSpring) {
                        currentStep += 1
                    }
                } else {
                    finishOnboarding()
                }
            } label: {
                Text(currentStep == totalSteps ? Loc.tr("start") : Loc.tr("continue"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(scheme == .dark ? Color.black : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(scheme == .dark ? Color.white : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)

            if currentStep == totalSteps && !isBiometricsEnabled && (!isPinSetupActive || pinInput.count < 4) {
                Button {
                    HapticManager.shared.touchLight()
                    finishOnboarding()
                } label: {
                    Text(Loc.tr("onboarding_security_skip"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 16)
    }

    private func finishOnboarding() {
        // 1. Guardar PIN si se configuró
        if isPinSetupActive && pinInput.count == 4 && pinInput == pinConfirmInput {
            KeychainVault.shared.saveAppPIN(pinInput)
            KeychainVault.shared.isAppLockEnabled = true
        }

        // 2. Guardar Biometría si se activó
        if isBiometricsEnabled {
            KeychainVault.shared.isBiometricAuthEnabled = true
            KeychainVault.shared.isAppLockEnabled = true
        }

        // 3. Crear Perfil en StorageEngine
        let cleanedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = cleanedName.isEmpty ? "Personal" : cleanedName
        let age = Int(userAgeText.trimmingCharacters(in: .whitespacesAndNewlines))

        let engine = StorageEngine.shared
        if let first = engine.profiles.first {
            var updated = first
            updated.name = finalName
            updated.age = age
            updated.description = profileDescription.isEmpty ? "Perfil Principal de Navegación" : profileDescription
            updated.accentColor = selectedColor
            engine.updateProfile(updated)
        } else {
            _ = engine.createProfile(
                name: finalName,
                age: age,
                description: profileDescription,
                color: selectedColor
            )
        }

        // 4. Iniciar Animación Cinemática Final
        withAnimation(LiquidAnimation.smoothSpring) {
            isShowingCinematicWelcome = true
        }
    }
}
