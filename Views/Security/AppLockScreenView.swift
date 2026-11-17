import SwiftUI
import LocalAuthentication

// MARK: - AppLockScreenView (Monochrome Liquid Glass App Lock)

public struct AppLockScreenView: View {
    @State private var pinInput: String = ""
    @State private var attemptsCount: Int = 0
    @State private var isShaking: Bool = false
    @State private var errorMessage: String? = nil

    @Environment(\.colorScheme) private var colorScheme
    public var onUnlocked: () -> Void

    public init(onUnlocked: @escaping () -> Void) {
        self.onUnlocked = onUnlocked
    }

    public var body: some View {
        let theme = ThemeManager.shared

        ZStack {
            // Fondo cristalino líquido desenfocado
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Cabecera de Bloqueo
                VStack(spacing: 12) {
                    LiquidIconView(
                        KeychainSecurityHelper.shared.isBiometricAuthEnabled ?
                            (KeychainSecurityHelper.shared.biometricType == .faceID ? .faceID : .touchID) :
                            .lockSSL,
                        size: 52,
                        color: theme.textPrimary(for: colorScheme)
                    )

                    Text("LiquidBrowser Protegido")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))

                    Text(errorMessage ?? "Introduce tu PIN de 4 dígitos para continuar")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(errorMessage != nil ? Color.red : theme.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Indicador visual de los 4 dígitos
                HStack(spacing: 16) {
                    ForEach(0..<4) { i in
                        ZStack {
                            Circle()
                                .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 1.5)
                                .frame(width: 18, height: 18)

                            if i < pinInput.count {
                                Circle()
                                    .fill(theme.textPrimary(for: colorScheme))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                }
                .modifier(ShakeEffect(shakes: isShaking ? 2 : 0))
                .animation(LiquidAnimation.snappySpring, value: isShaking)
                .padding(.vertical, 8)

                // Teclado Numérico Monocromo Artesanal
                keypadGrid
                    .padding(.horizontal, 40)

                Spacer()

                // Botón Biométrico si está disponible
                if KeychainSecurityHelper.shared.isBiometricAuthEnabled && KeychainSecurityHelper.shared.canEvaluateBiometrics {
                    Button(action: {
                        triggerBiometrics()
                    }) {
                        HStack(spacing: 8) {
                            LiquidIconView(KeychainSecurityHelper.shared.biometricType == .faceID ? .faceID : .touchID,
                                           size: 18,
                                           color: theme.textPrimary(for: colorScheme))

                            Text(KeychainSecurityHelper.shared.biometricType == .faceID ? "Desbloquear con Face ID" : "Desbloquear con Touch ID")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .liquidGlass(config: .chip)
                    }
                    .pressableFeedback()
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            if KeychainSecurityHelper.shared.isBiometricAuthEnabled {
                triggerBiometrics()
            }
        }
    }

    // MARK: - Keypad Grid

    @ViewBuilder
    private var keypadGrid: some View {
        let theme = ThemeManager.shared
        let numbers = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "delete"]
        ]

        VStack(spacing: 14) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Spacer().frame(width: 68, height: 68)
                        } else if key == "delete" {
                            Button(action: {
                                HapticManager.shared.touchLight()
                                if !pinInput.isEmpty { pinInput.removeLast() }
                            }) {
                                LiquidIconView(.close, size: 20, color: theme.textPrimary(for: colorScheme))
                                    .frame(width: 68, height: 68)
                                    .liquidGlass(config: .chip)
                            }
                            .pressableFeedback()
                        } else {
                            Button(action: {
                                handleDigitInput(key)
                            }) {
                                Text(key)
                                    .font(.system(size: 26, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                                    .frame(width: 68, height: 68)
                                    .liquidGlass(config: .chip)
                            }
                            .pressableFeedback()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func handleDigitInput(_ digit: String) {
        guard pinInput.count < 4 else { return }
        HapticManager.shared.touchLight()
        pinInput.append(digit)

        if pinInput.count == 4 {
            verifyPIN()
        }
    }

    private func verifyPIN() {
        if KeychainSecurityHelper.shared.verifyPIN(pinInput) {
            HapticManager.shared.notifySuccess()
            withAnimation(LiquidAnimation.interactiveSpring) {
                onUnlocked()
            }
        } else {
            HapticManager.shared.notifyError()
            attemptsCount += 1
            errorMessage = "PIN incorrecto (\(attemptsCount) intento\(attemptsCount > 1 ? "s" : ""))"
            isShaking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.isShaking = false
                self.pinInput = ""
            }
        }
    }

    private func triggerBiometrics() {
        KeychainSecurityHelper.shared.authenticateWithBiometrics { success in
            DispatchQueue.main.async {
                if success {
                    HapticManager.shared.notifySuccess()
                    withAnimation(LiquidAnimation.interactiveSpring) {
                        self.onUnlocked()
                    }
                }
            }
        }
    }
}

// MARK: - ShakeEffect Helper

public struct ShakeEffect: GeometryEffect {
    public var amount: CGFloat = 8
    public var shakesPerUnit: CGFloat = 3
    public var animatableData: CGFloat

    public init(shakes: Int) {
        self.animatableData = CGFloat(shakes)
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit),
            y: 0))
    }
}
