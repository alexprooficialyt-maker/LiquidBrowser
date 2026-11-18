import SwiftUI
import LocalAuthentication

// MARK: - OnboardingFlowView (5-Step Apple Liquid Glass Sequence)

public struct OnboardingFlowView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    public var onFinished: () -> Void

    @State private var currentStep: Int = 1
    private let totalSteps: Int = 5

    // Paso 1: Idioma y Búsqueda en Tiempo Real
    @State private var selectedLanguage: AppLanguage = LocalizationManager.shared.currentLanguage
    @State private var languageSearchQuery: String = ""

    // Paso 2: Perfil Inicial (Solo Nombre, Sin Edad ni Descripción)
    @State private var userName: String = ""
    @State private var selectedColor: ProfileAccentColor = .monochrome
    @State private var selectedIcon: LiquidIconType = .userProfile

    // Paso 3: Apariencia
    @State private var selectedTheme: AppThemeMode = ThemeManager.shared.currentMode

    // Paso 4: Buscador Predeterminado (8 Motores Oficiales)
    @State private var selectedEngine: SearchEngineType = .google

    // Paso 5: Seguridad y Detección de Hardware
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
                // Barra de Progreso Superior Segmentada Apple
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
                .padding(.bottom, 20)

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

                // Barra Inferior de Navegación Fija
                bottomNavigationControls(theme: theme, scheme: effectiveScheme)
            }
        }
        .fullScreenCover(isPresented: $isShowingCinematicWelcome) {
            WelcomeLetterAnimationView(
                userName: userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "SmartBot" : userName,
                onComplete: {
                    withAnimation(LiquidAnimation.smoothSpring) {
                        StorageEngine.shared.hasCompletedOnboarding = true
                        onFinished()
                    }
                }
            )
        }
    }

    // MARK: - Paso 1: Idioma con Búsqueda en Tiempo Real y 15 Idiomas

    @ViewBuilder
    private func step1LanguageView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let filteredLanguages = LocalizationManager.shared.filterLanguages(query: languageSearchQuery)

        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.globeLanguage, size: 40, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step1_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step1_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Barra de Búsqueda de Idiomas
                HStack(spacing: 10) {
                    LiquidIconView(.search, size: 16, color: theme.textSecondary(for: scheme))

                    TextField("Buscar idioma / Search language...", text: $languageSearchQuery)
                        .font(.system(size: 15))
                        .foregroundStyle(theme.textPrimary(for: scheme))
                        .autocorrectionDisabled()

                    if !languageSearchQuery.isEmpty {
                        Button {
                            languageSearchQuery = ""
                        } label: {
                            LiquidIconView(.close, size: 14, color: theme.textSecondary(for: scheme))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(theme.surfaceElevated(for: scheme))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                }
                .padding(.horizontal, 20)

                // Lista de Idiomas
                VStack(spacing: 10) {
                    ForEach(filteredLanguages) { lang in
                        Button {
                            HapticManager.shared.touchSelection()
                            selectedLanguage = lang
                            LocalizationManager.shared.currentLanguage = lang
                        } label: {
                            HStack(spacing: 14) {
                                LanguageFlagView(language: lang, size: 28)

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
                            .padding(.vertical, 12)
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
                .padding(.top, 4)
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Paso 2: Perfil Inicial (Nombre Únicamente y Círculos 36x36)

    @ViewBuilder
    private func step2ProfileView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Vista previa de Avatar
                ZStack {
                    Circle()
                        .fill(selectedColor.swatchColor.opacity(0.18))
                        .frame(width: 84, height: 84)

                    LiquidIconView(selectedIcon, size: 40, color: selectedColor.color(for: scheme))
                }
                .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step2_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step2_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Campo de Nombre Único (Obligatorio)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Loc.tr("onboarding_step2_name_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField(Loc.tr("onboarding_step2_name_placeholder"), text: $userName)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                            }

                        if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Introduce tu nombre para continuar")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(theme.textSecondary(for: scheme).opacity(0.7))
                                .padding(.leading, 4)
                        }
                    }

                    // Selector de Color con Círculos Profesionales de 36x36 pt
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Loc.tr("onboarding_step2_color_label"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(ProfileAccentColor.allCases) { color in
                                    ProfileColorCircleView(
                                        color: color,
                                        isSelected: selectedColor == color,
                                        size: 36
                                    )
                                    .onTapGesture {
                                        HapticManager.shared.touchSelection()
                                        selectedColor = color
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Selector de Icono de Perfil
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icono de Perfil")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        let availableIcons: [LiquidIconType] = [
                            .userProfile, .star, .shieldActive, .bookmark, .briefcase, .sparkler
                        ]

                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.rawValue) { icon in
                                Button {
                                    HapticManager.shared.touchSelection()
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(selectedIcon == icon ? theme.textPrimary(for: scheme).opacity(0.12) : theme.surfaceElevated(for: scheme))
                                            .frame(width: 44, height: 44)

                                        LiquidIconView(
                                            icon,
                                            size: 20,
                                            color: selectedIcon == icon ? theme.textPrimary(for: scheme) : theme.textSecondary(for: scheme)
                                        )
                                    }
                                    .overlay {
                                        if selectedIcon == icon {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 1.5)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Paso 3: Apariencia (Claro, Oscuro, Sistema)

    @ViewBuilder
    private func step3AppearanceView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                LiquidIconView(.eye, size: 40, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step3_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step3_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 14) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Button {
                            HapticManager.shared.touchSelection()
                            selectedTheme = mode
                            ThemeManager.shared.currentMode = mode
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(theme.surfaceElevated(for: scheme))
                                        .frame(width: 44, height: 44)

                                    LiquidIconView(
                                        mode == .dark ? .moonDark : (mode == .light ? .sunLight : .gear),
                                        size: 20,
                                        color: theme.textPrimary(for: scheme)
                                    )
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(mode.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))

                                    Text(modeDescription(mode))
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                }

                                Spacer()

                                if selectedTheme == mode {
                                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                                }
                            }
                            .padding(16)
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
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
    }

    private func modeDescription(_ mode: AppThemeMode) -> String {
        switch mode {
        case .system: return "Se adapta automáticamente a la configuración de iOS"
        case .light: return "Fondo blanco puro y elementos cristalinos claros"
        case .dark: return "Negro absoluto OLED con reflejos especulares de cristal"
        }
    }

    // MARK: - Paso 4: Buscador Predeterminado (8 Motores Oficiales)

    @ViewBuilder
    private func step4SearchEngineView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                LiquidIconView(.search, size: 40, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step4_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step4_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 10) {
                    ForEach(SearchEngineType.allCases) { engine in
                        Button {
                            HapticManager.shared.touchSelection()
                            selectedEngine = engine
                            UserDefaults.standard.set(engine.rawValue, forKey: "smartbot_default_search_engine")
                        } label: {
                            HStack(spacing: 16) {
                                SearchEngineLogoView(engine: engine, size: 32)
                                    .frame(width: 40, height: 40)
                                    .background(theme.surfaceElevated(for: scheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(engine.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: scheme))

                                    Text(engineSubtitle(engine))
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(theme.textSecondary(for: scheme))
                                }

                                Spacer()

                                if selectedEngine == engine {
                                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
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
            .padding(.bottom, 24)
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

    // MARK: - Paso 5: Seguridad y Detección de Hardware

    @ViewBuilder
    private func step5SecurityView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let biometryHelper = DeviceBiometryHelper.shared
        let appleGreen = Color(hex: "34C759")

        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                LiquidIconView(biometryHelper.biometryIconType, size: 44, color: theme.textPrimary(for: scheme))
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(Loc.tr("onboarding_step5_title"))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("onboarding_step5_sub"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 16) {
                    // Tarjeta de Detección de Hardware
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(theme.surfaceElevated(for: scheme))
                                .frame(width: 44, height: 44)

                            LiquidIconView(biometryHelper.biometryIconType, size: 22, color: theme.textPrimary(for: scheme))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(biometryHelper.biometryName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))

                            Text(biometryHelper.isBiometricsAvailable ? "Hardware detectado y listo" : "Disponible mediante código")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                        }

                        Spacer()

                        Toggle("", isOn: $isBiometricsEnabled)
                            .labelsHidden()
                            .tint(appleGreen)
                            .onChange(of: isBiometricsEnabled) { _, enabled in
                                if enabled {
                                    HapticManager.shared.touchSelection()
                                    Task {
                                        _ = await biometryHelper.authenticate(reason: "Activar acceso seguro a SmartBot Browser")
                                    }
                                }
                            }
                    }
                    .padding(16)
                    .liquidGlassCard(cornerRadius: 18)

                    // Tarjeta de Código PIN
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(theme.surfaceElevated(for: scheme))
                                    .frame(width: 44, height: 44)

                                LiquidIconView(.lockSSL, size: 20, color: theme.textPrimary(for: scheme))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Código PIN de 4 Dígitos")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Text("Protección adicional para perfiles y pestañas")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }

                            Spacer()

                            Toggle("", isOn: $isPinSetupActive)
                                .labelsHidden()
                                .tint(appleGreen)
                                .onChange(of: isPinSetupActive) { _, active in
                                    HapticManager.shared.touchSelection()
                                    if !active {
                                        pinInput = ""
                                        pinConfirmInput = ""
                                        isConfirmingPin = false
                                        pinErrorMessage = nil
                                    }
                                }
                        }

                        // Teclado/Input de PIN si está activo
                        if isPinSetupActive {
                            VStack(spacing: 12) {
                                Text(isConfirmingPin ? "Confirma tu PIN" : "Introduce un PIN de 4 dígitos")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(theme.textSecondary(for: scheme))

                                HStack(spacing: 16) {
                                    let currentDigits = isConfirmingPin ? pinConfirmInput : pinInput
                                    ForEach(0..<4, id: \.self) { idx in
                                        Circle()
                                            .fill(idx < currentDigits.count ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.18))
                                            .frame(width: 14, height: 14)
                                    }
                                }
                                .padding(.vertical, 8)

                                // Campo invisible para teclado nativo
                                SecureField("", text: isConfirmingPin ? $pinConfirmInput : $pinInput)
                                    .keyboardType(.numberPad)
                                    .frame(width: 1, height: 1)
                                    .opacity(0.01)
                                    .onChange(of: isConfirmingPin ? pinConfirmInput : pinInput) { _, val in
                                        handlePinDigitChange(val)
                                    }

                                if let err = pinErrorMessage {
                                    Text(err)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(16)
                    .liquidGlassCard(cornerRadius: 18)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
    }

    private func handlePinDigitChange(_ val: String) {
        if !isConfirmingPin {
            if val.count > 4 {
                pinInput = String(val.prefix(4))
            }
            if pinInput.count == 4 {
                HapticManager.shared.touchLight()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(LiquidAnimation.smoothSpring) {
                        isConfirmingPin = true
                    }
                }
            }
        } else {
            if val.count > 4 {
                pinConfirmInput = String(val.prefix(4))
            }
            if pinConfirmInput.count == 4 {
                if pinConfirmInput == pinInput {
                    HapticManager.shared.notifySuccess()
                    pinErrorMessage = nil
                } else {
                    HapticManager.shared.notifyWarning()
                    pinErrorMessage = "Los códigos PIN no coinciden. Inténtalo de nuevo."
                    pinConfirmInput = ""
                }
            }
        }
    }

    // MARK: - Controles de Navegación Inferior

    private var canProceed: Bool {
        if currentStep == 2 {
            return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    @ViewBuilder
    private func bottomNavigationControls(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Botón Atrás
                if currentStep > 1 {
                    Button {
                        HapticManager.shared.touchLight()
                        withAnimation(LiquidAnimation.smoothSpring) {
                            currentStep -= 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            LiquidIconView(.chevronLeft, size: 14, color: theme.textPrimary(for: scheme))
                            Text(Loc.tr("back"))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))
                        }
                        .frame(height: 52)
                        .padding(.horizontal, 18)
                        .background(theme.surfaceElevated(for: scheme))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Botón Continuar / Comenzar
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
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.45)
            }
            .padding(.horizontal, 24)

            // Opción Omitir en Paso de Seguridad
            if currentStep == totalSteps && !isBiometricsEnabled && !isPinSetupActive {
                Button {
                    HapticManager.shared.touchLight()
                    finishOnboarding()
                } label: {
                    Text(Loc.tr("onboarding_security_skip"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 14)
    }

    private func finishOnboarding() {
        // 1. Guardar PIN si fue configurado y verificado
        if isPinSetupActive && pinInput.count == 4 && pinInput == pinConfirmInput {
            KeychainVault.shared.saveAppPIN(pinInput)
            KeychainVault.shared.isAppLockEnabled = true
        }

        // 2. Guardar Biometría si fue activada
        if isBiometricsEnabled {
            KeychainVault.shared.isBiometricAuthEnabled = true
            KeychainVault.shared.isAppLockEnabled = true
        }

        // 3. Crear o actualizar Perfil en StorageEngine (solo con nombre, color e icono)
        let cleanedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = cleanedName.isEmpty ? "Personal" : cleanedName

        let engine = StorageEngine.shared
        if let first = engine.profiles.first {
            var updated = first
            updated.name = finalName
            updated.accentColor = selectedColor
            updated.iconType = selectedIcon
            engine.updateProfile(updated)
        } else {
            _ = engine.createProfile(
                name: finalName,
                color: selectedColor,
                icon: selectedIcon
            )
        }

        // 4. Iniciar Animación Cinemática de Bienvenida de Apple
        withAnimation(LiquidAnimation.smoothSpring) {
            isShowingCinematicWelcome = true
        }
    }
}
