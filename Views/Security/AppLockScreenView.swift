import SwiftUI
import LocalAuthentication

// MARK: - AppLockScreenView (Persistent Apple Liquid Glass Lock Screen)

public struct AppLockScreenView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    public var onUnlocked: () -> Void

    @State private var pinInput: String = ""
    @State private var attemptsCount: Int = 0
    @State private var isShaking: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isBiometricScanning: Bool = false

    public init(onUnlocked: @escaping () -> Void = {}) {
        self.onUnlocked = onUnlocked
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let bioType = KeychainVault.shared.biometricType
        let hasBio = KeychainVault.shared.isBiometricAuthEnabled && KeychainVault.shared.canUseBiometrics

        ZStack {
            // Fondo de Cristal Monocromo Protegido
            theme.background(for: scheme)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Icono Central de Bloqueo / Biometría
                ZStack {
                    Circle()
                        .fill(theme.glassMaterialFill(for: scheme))
                        .frame(width: 88, height: 88)
                        .overlay {
                            Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                        }

                    if hasBio {
                        AnimatedBiometricIcon(type: bioType, isScanning: isBiometricScanning, size: 44)
                    } else {
                        LiquidIconView(.lockSSL, size: 40, color: theme.textPrimary(for: scheme))
                    }
                }
                .padding(.bottom, 8)

                // Títulos Informativos
                VStack(spacing: 6) {
                    Text(Loc.tr("lock_title"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(hasBio ? (bioType == .faceID ? Loc.tr("lock_subtitle_faceid") : Loc.tr("lock_subtitle_touchid")) : Loc.tr("lock_subtitle_pin"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // 4 Puntos de Estado de PIN
                HStack(spacing: 18) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < pinInput.count ? theme.textPrimary(for: scheme) : theme.textPrimary(for: scheme).opacity(0.18))
                            .frame(width: 15, height: 15)
                            .overlay {
                                Circle().strokeBorder(theme.specularBorder(for: scheme), lineWidth: 0.5)
                            }
                            .scaleEffect(index < pinInput.count ? 1.15 : 1.0)
                            .animation(LiquidAnimation.snappySpring, value: pinInput.count)
                    }
                }
                .modifier(ShakeEffect(shakes: isShaking ? 3 : 0))
                .animation(LiquidAnimation.snappySpring, value: isShaking)
                .padding(.vertical, 8)

                // Mensaje de Error si falla
                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.95, green: 0.25, blue: 0.25))
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    Text(" ")
                        .font(.system(size: 13))
                }

                // Teclado Numérico 3x4 Estilo Apple
                numericKeypad(theme: theme, scheme: scheme, hasBio: hasBio, bioType: bioType)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            if hasBio {
                triggerBiometrics()
            }
        }
    }

    // MARK: - Teclado Numérico Apple Liquid Glass

    @ViewBuilder
    private func numericKeypad(theme: ThemeManager, scheme: ColorScheme, hasBio: Bool, bioType: LABiometryType) -> some View {
        let keys = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["bio", "0", "delete"]
        ]

        VStack(spacing: 14) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(row, id: \.self) { key in
                        if key == "bio" {
                            if hasBio {
                                Button {
                                    HapticManager.shared.touchLight()
                                    triggerBiometrics()
                                } label: {
                                    LiquidIconView(bioType == .faceID ? .faceID : .touchID, size: 28, color: theme.textPrimary(for: scheme))
                                        .frame(width: 72, height: 72)
                                        .background(theme.surfaceElevated(for: scheme).opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            } else {
                                Color.clear.frame(width: 72, height: 72)
                            }
                        } else if key == "delete" {
                            Button {
                                HapticManager.shared.touchLight()
                                if !pinInput.isEmpty {
                                    pinInput.removeLast()
                                    errorMessage = nil
                                }
                            } label: {
                                LiquidIconView(.close, size: 22, color: theme.textPrimary(for: scheme))
                                    .frame(width: 72, height: 72)
                                    .background(theme.surfaceElevated(for: scheme).opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .opacity(pinInput.isEmpty ? 0.3 : 1.0)
                        } else {
                            Button {
                                HapticManager.shared.touchSelection()
                                handleKeyInput(key)
                            } label: {
                                Text(key)
                                    .font(.system(size: 28, weight: .light, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))
                                    .frame(width: 72, height: 72)
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

    private func handleKeyInput(_ digit: String) {
        guard pinInput.count < 4 else { return }
        pinInput.append(digit)

        if pinInput.count == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                validatePin()
            }
        }
    }

    private func validatePin() {
        let isSuccess = BiometricLockManager.shared.verifyPIN(pinInput)
        if isSuccess {
            HapticManager.shared.notifySuccess()
            withAnimation(LiquidAnimation.interactiveSpring) {
                onUnlocked()
            }
        } else {
            HapticManager.shared.notifyError()
            attemptsCount += 1
            errorMessage = Loc.tr("lock_pin_incorrect")
            isShaking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.isShaking = false
                self.pinInput = ""
            }
        }
    }

    private func triggerBiometrics() {
        isBiometricScanning = true
        BiometricLockManager.shared.triggerBiometricUnlock { success in
            DispatchQueue.main.async {
                self.isBiometricScanning = false
                if success {
                    self.onUnlocked()
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
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
