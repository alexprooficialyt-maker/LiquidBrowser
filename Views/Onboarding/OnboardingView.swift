import SwiftUI

public struct OnboardingView: View {
    @State private var currentStep: Int = 0
    @State private var nameInput: String = ""
    @State private var ageSelection: Int = 24
    @State private var appearAnimation: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    public var onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        ZStack {
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                Group {
                    switch currentStep {
                    case 0:
                        welcomeStepView
                    case 1:
                        nameStepView
                    case 2:
                        ageStepView
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(LiquidAnimation.gentleSpring) {
                appearAnimation = true
            }
        }
    }

    @ViewBuilder
    private var topBar: some View {
        HStack {
            if currentStep > 0 {
                Button(action: {
                    HapticManager.shared.touchLight()
                    withAnimation(LiquidAnimation.interactiveSpring) {
                        currentStep -= 1
                    }
                }) {
                    HStack(spacing: 6) {
                        LiquidIconView(.back, size: 14)
                        Text("Atrás")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                }
            }

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<3) { stepIndex in
                    Capsule()
                        .fill(
                            stepIndex == currentStep ?
                            (colorScheme == .dark ? Color.white : Color.black) :
                            (colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.14))
                        )
                        .frame(width: stepIndex == currentStep ? 24 : 6, height: 6)
                        .animation(LiquidAnimation.interactiveSpring, value: currentStep)
                }
            }
        }
        .frame(height: 32)
    }

    @ViewBuilder
    private var welcomeStepView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                    .frame(width: 140, height: 140)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(ThemeEngine.shared.borderSpecular(for: colorScheme), lineWidth: 0.5)
                    }
                    .shadow(color: ThemeEngine.shared.shadowColor(for: colorScheme), radius: 16, y: 6)

                LiquidIconView(.shieldBlocker, size: 38, color: ThemeEngine.shared.textPrimary(for: colorScheme), lineWidth: 1.6)
            }
            .scaleEffect(appearAnimation ? 1.0 : 0.8)
            .opacity(appearAnimation ? 1.0 : 0.0)

            VStack(spacing: 10) {
                Text("LiquidBrowser")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Text("Navegador web puro, sin rastreadores ni distracciones. Diseñado con arquitectura de cristal líquido.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                featureBullet(icon: .lockSSL, title: "Privacidad Total", subtitle: "Sin perfiles publicitarios ni asistentes innecesarios.")
                featureBullet(icon: .spaceFolder, title: "Espacios de Trabajo", subtitle: "Organiza pestañas por contextos reales con iconos propios.")
                featureBullet(icon: .speedArrow, title: "Rendimiento Nativo", subtitle: "Motor WebKit acelerado con navegación ultra rápida.")
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func featureBullet(icon: LiquidIconType, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    .frame(width: 36, height: 36)

                LiquidIconView(icon, size: 16, color: ThemeEngine.shared.textPrimary(for: colorScheme), lineWidth: 1.5)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .liquidGlass(config: .chip)
    }

    @ViewBuilder
    private var nameStepView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                    .frame(width: 90, height: 90)

                LiquidIconView(.spacePrivate, size: 34, color: ThemeEngine.shared.textPrimary(for: colorScheme), lineWidth: 1.5)
            }

            VStack(spacing: 8) {
                Text("¿Cómo te llamas?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Text("Personaliza el saludo y la barra principal de tu navegador.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                HStack(spacing: 14) {
                    LiquidIconView(.search, size: 18, color: ThemeEngine.shared.textSecondary(for: colorScheme))

                    TextField("Tu nombre o alias", text: $nameInput)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))
                        .autocorrectionDisabled()
                        .submitLabel(.continue)
                        .onSubmit {
                            if !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                advanceToNext()
                            }
                        }

                    if !nameInput.isEmpty {
                        Button(action: { nameInput = "" }) {
                            LiquidIconView(.close, size: 14, color: ThemeEngine.shared.textSecondary(for: colorScheme))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .liquidGlass(config: .card)
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var ageStepView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                    .frame(width: 90, height: 90)

                LiquidIconView(.sliderAdjust, size: 34, color: ThemeEngine.shared.textPrimary(for: colorScheme), lineWidth: 1.5)
            }

            VStack(spacing: 8) {
                Text("Tu Edad")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Text("Ajusta los filtros de seguridad y tipografía adecuados.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                Text("\(ageSelection) años")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))

                Picker("Edad", selection: $ageSelection) {
                    ForEach(12...99, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)
                .liquidGlass(config: .card)
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var bottomControls: some View {
        VStack(spacing: 12) {
            Button(action: {
                advanceToNext()
            }) {
                HStack(spacing: 10) {
                    Text(currentStep == 2 ? "Comenzar a navegar" : "Continuar")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    LiquidIconView(currentStep == 2 ? .check : .forward, size: 16)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                }
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.15),
                            lineWidth: 0.5
                        )
                }
                .shadow(
                    color: ThemeEngine.shared.shadowColor(for: colorScheme).opacity(0.3),
                    radius: 12,
                    y: 4
                )
            }
            .pressableFeedback()

            if currentStep > 0 {
                Button(action: {
                    finishOnboarding()
                }) {
                    Text("Omitir")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(ThemeEngine.shared.textTertiary(for: colorScheme))
                }
            }
        }
    }

    private func advanceToNext() {
        HapticManager.shared.touchMedium()
        if currentStep < 2 {
            withAnimation(LiquidAnimation.interactiveSpring) {
                currentStep += 1
            }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmed.isEmpty ? "Usuario" : trimmed

        UserDefaults.standard.set(resolvedName, forKey: "userName")
        UserDefaults.standard.set(ageSelection, forKey: "userAge")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        HapticManager.shared.notifySuccess()
        onFinished()
    }
}

extension LiquidIconType {
    public static var speedArrow: LiquidIconType { .forward }
}
