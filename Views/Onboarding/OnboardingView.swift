import SwiftUI
import LocalAuthentication

// MARK: - OnboardingView (4-Step Monochrome Liquid Glass Flow)

public struct OnboardingView: View {
    @State private var currentStep: Int = 0

    // Paso 1: Identidad
    @State private var nameInput: String = ""
    @State private var ageSelection: Int = 24

    // Paso 2: Apariencia
    @State private var selectedThemeMode: AppThemeMode = .system

    // Paso 3: Motor de Búsqueda
    @State private var selectedEngine: String = "Google"

    // Paso 4: Seguridad (PIN / Biometría)
    @State private var enableAppLock: Bool = false
    @State private var pinCode: String = ""
    @State private var enableBiometrics: Bool = false
    @State private var isPinSetupActive: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    public var onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        let theme = ThemeManager.shared

        ZStack {
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior de progreso de 4 pasos
                topStepIndicator
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                // Contenido por pasos
                Group {
                    switch currentStep {
                    case 0:
                        identityStepView
                    case 1:
                        appearanceStepView
                    case 2:
                        searchEngineStepView
                    case 3:
                        securityStepView
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                // Controles de navegación inferiores
                bottomNavigationControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Top Step Indicator

    @ViewBuilder
    private var topStepIndicator: some View {
        let theme = ThemeManager.shared

        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(index <= currentStep ?
                          theme.textPrimary(for: colorScheme) :
                          theme.textTertiary(for: colorScheme).opacity(0.3))
                    .frame(height: 3)
                    .animation(LiquidAnimation.interactiveSpring, value: currentStep)
            }
        }
    }

    // MARK: - Paso 1: Identidad

    @ViewBuilder
    private var identityStepView: some View {
        let theme = ThemeManager.shared

        VStack(spacing: 24) {
            LiquidIconView(.userProfile, size: 48, color: theme.textPrimary(for: colorScheme))

            VStack(spacing: 6) {
                Text("Bienvenido a Liquid")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                Text("Personaliza tu experiencia de navegación nativa.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                // Campo de Nombre
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tu nombre")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary(for: colorScheme))

                    TextField("¿Cómo te llamas?", text: $nameInput)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlass(config: .card)
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                }

                // Selector de Edad
                VStack(alignment: .leading, spacing: 6) {
                    Text("Edad")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textSecondary(for: colorScheme))

                    HStack {
                        Text("\(ageSelection) años")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))

                        Spacer()

                        Stepper("", value: $ageSelection, in: 10...99)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .liquidGlass(config: .card)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Paso 2: Apariencia

    @ViewBuilder
    private var appearanceStepView: some View {
        let theme = ThemeManager.shared

        VStack(spacing: 24) {
            LiquidIconView(.sliderAdjust, size: 48, color: theme.textPrimary(for: colorScheme))

            VStack(spacing: 6) {
                Text("Elige tu Apariencia")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                Text("Monocromo estricto con cristal líquido.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
            }

            VStack(spacing: 12) {
                ForEach(AppThemeMode.allCases, id: \.self) { mode in
                    let isSelected = (selectedThemeMode == mode)

                    Button(action: {
                        HapticManager.shared.touchLight()
                        selectedThemeMode = mode
                        ThemeManager.shared.currentMode = mode
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(mode == .dark ? Color.black : (mode == .light ? Color.white : Color.gray.opacity(0.3)))
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        Circle().strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                                    }

                                if isSelected {
                                    LiquidIconView(.checkmark, size: 14, color: mode == .dark ? Color.white : Color.black)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.title)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                                Text(mode == .light ? "Cristal esmerilado blanco" : (mode == .dark ? "Cristal ahumado negro" : "Adaptación al sistema"))
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlass(config: .card)
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(theme.textPrimary(for: colorScheme), lineWidth: 1.5)
                            }
                        }
                    }
                    .pressableFeedback()
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Paso 3: Motor de Búsqueda

    @ViewBuilder
    private var searchEngineStepView: some View {
        let theme = ThemeManager.shared

        let engines: [(name: String, icon: LiquidIconType, desc: String)] = [
            ("Google", .googleSearch, "Resultados completos y velocidad global."),
            ("DuckDuckGo", .duckDuckGoSearch, "Privacidad estricta sin rastreo."),
            ("Brave", .braveSearch, "Buscador independiente sin sesgo."),
            ("Ecosia", .ecosiaSearch, "Búsquedas ecológicas.")
        ]

        VStack(spacing: 24) {
            LiquidIconView(.search, size: 48, color: theme.textPrimary(for: colorScheme))

            VStack(spacing: 6) {
                Text("Motor de Búsqueda")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                Text("Selecciona cómo explorar la web por defecto.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
            }

            VStack(spacing: 10) {
                ForEach(engines, id: \.name) { item in
                    let isSelected = (selectedEngine == item.name)

                    Button(action: {
                        HapticManager.shared.touchLight()
                        selectedEngine = item.name
                    }) {
                        HStack(spacing: 14) {
                            LiquidIconView(item.icon, size: 22, color: theme.textPrimary(for: colorScheme))
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                                Text(item.desc)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                            }

                            Spacer()

                            if isSelected {
                                LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: colorScheme))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .liquidGlass(config: .card)
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(theme.textPrimary(for: colorScheme), lineWidth: 1.5)
                            }
                        }
                    }
                    .pressableFeedback()
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Paso 4: Seguridad (PIN y Biometría)

    @ViewBuilder
    private var securityStepView: some View {
        let theme = ThemeManager.shared

        VStack(spacing: 22) {
            LiquidIconView(.shieldBlocker, size: 48, color: theme.textPrimary(for: colorScheme))

            VStack(spacing: 6) {
                Text("Protección de Acceso")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                Text("Bloquea LiquidBrowser con PIN o Face ID al abrirlo.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                // Toggle de Bloqueo General
                Toggle(isOn: $enableAppLock) {
                    HStack(spacing: 12) {
                        LiquidIconView(.lockSSL, size: 18, color: theme.textPrimary(for: colorScheme))
                        Text("Activar bloqueo de app")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                    }
                }
                .tint(theme.textPrimary(for: colorScheme))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .liquidGlass(config: .card)

                if enableAppLock {
                    // Biometría Toggle
                    if KeychainSecurityHelper.shared.canEvaluateBiometrics {
                        Toggle(isOn: $enableBiometrics) {
                            HStack(spacing: 12) {
                                LiquidIconView(KeychainSecurityHelper.shared.biometricType == .faceID ? .faceID : .touchID,
                                               size: 18,
                                               color: theme.textPrimary(for: colorScheme))
                                Text(KeychainSecurityHelper.shared.biometricType == .faceID ? "Usar Face ID" : "Usar Touch ID")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                        .tint(theme.textPrimary(for: colorScheme))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .liquidGlass(config: .card)
                    }

                    // PIN numérico de 4 dígitos
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PIN de 4 dígitos (obligatorio para bloqueo)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        HStack(spacing: 14) {
                            ForEach(0..<4) { i in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(theme.cardBackground(for: colorScheme))
                                        .frame(height: 50)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                                        }

                                    if i < pinCode.count {
                                        Circle()
                                            .fill(theme.textPrimary(for: colorScheme))
                                            .frame(width: 10, height: 10)
                                    }
                                }
                            }
                        }

                        // Teclado numérico artesanal
                        pinKeypadView
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Teclado Numérico Artesanal

    @ViewBuilder
    private var pinKeypadView: some View {
        let theme = ThemeManager.shared
        let numbers = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "delete"]
        ]

        VStack(spacing: 8) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { val in
                        if val.isEmpty {
                            Spacer().frame(maxWidth: .infinity)
                        } else if val == "delete" {
                            Button(action: {
                                HapticManager.shared.touchLight()
                                if !pinCode.isEmpty { pinCode.removeLast() }
                            }) {
                                LiquidIconView(.close, size: 16, color: theme.textPrimary(for: colorScheme))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .liquidGlass(config: .chip)
                            }
                            .pressableFeedback()
                        } else {
                            Button(action: {
                                HapticManager.shared.touchLight()
                                if pinCode.count < 4 { pinCode.append(val) }
                            }) {
                                Text(val)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .liquidGlass(config: .chip)
                            }
                            .pressableFeedback()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Botones de Navegación

    @ViewBuilder
    private var bottomNavigationControls: some View {
        let theme = ThemeManager.shared

        VStack(spacing: 12) {
            Button(action: {
                advanceToNextStep()
            }) {
                HStack(spacing: 8) {
                    Text(currentStep == 3 ? "Comenzar a Navegar" : "Continuar")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    LiquidIconView(.chevronRight, size: 14, color: colorScheme == .dark ? Color.black : Color.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: theme.shadowColor(for: colorScheme), radius: 10, y: 4)
            }
            .pressableFeedback()

            if currentStep > 0 {
                Button(action: {
                    finishOnboarding()
                }) {
                    Text("Omitir configuración")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(theme.textTertiary(for: colorScheme))
                }
            }
        }
    }

    // MARK: - Flow Handlers

    private func advanceToNextStep() {
        HapticManager.shared.touchMedium()

        if currentStep == 3 {
            finishOnboarding()
        } else {
            withAnimation(LiquidAnimation.interactiveSpring) {
                currentStep += 1
            }
        }
    }

    private func finishOnboarding() {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? "Usuario" : trimmedName

        UserDefaults.standard.set(resolvedName, forKey: "userName")
        UserDefaults.standard.set(ageSelection, forKey: "userAge")
        UserDefaults.standard.set(selectedEngine, forKey: "searchEngine")

        if enableAppLock && pinCode.count == 4 {
            KeychainSecurityHelper.shared.savePIN(pinCode)
            KeychainSecurityHelper.shared.isAppLockEnabled = true
            KeychainSecurityHelper.shared.isBiometricAuthEnabled = enableBiometrics
        } else {
            KeychainSecurityHelper.shared.isAppLockEnabled = false
        }

        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        HapticManager.shared.notifySuccess()
        onFinished()
    }
}
