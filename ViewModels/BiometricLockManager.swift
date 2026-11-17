import SwiftUI
import LocalAuthentication

// MARK: - BiometricLockManager (@Observable App Lock & Security State)

@MainActor
@Observable
public final class BiometricLockManager {
    public static let shared = BiometricLockManager()

    // Estado Reactivo de Bloqueo
    public var isAppLocked: Bool = false
    public var isAuthenticating: Bool = false
    public var lastBackgroundTime: Date? = nil

    private init() {
        // Al instanciar, si el bloqueo está activo, bloquear síncronamente antes de renderizar
        if KeychainVault.shared.isAppLockEnabled {
            self.isAppLocked = true
        }
    }

    // MARK: - Hardware Biometry Capabilities

    public var biometricType: LABiometryType {
        KeychainVault.shared.biometricType
    }

    public var biometricDisplayName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "PIN"
        }
    }

    public var unlockPromptTitle: String {
        switch biometricType {
        case .faceID:
            return Loc.tr("lock_subtitle_faceid")
        case .touchID:
            return Loc.tr("lock_subtitle_touchid")
        default:
            return Loc.tr("lock_subtitle_pin")
        }
    }

    // MARK: - Lifecycle ScenePhase Transitions

    public func handleScenePhaseChange(_ phase: ScenePhase) {
        guard KeychainVault.shared.isAppLockEnabled else {
            isAppLocked = false
            return
        }

        switch phase {
        case .background:
            // Al pasar a segundo plano, bloquear inmediatamente
            isAppLocked = true
            lastBackgroundTime = Date()

        case .inactive:
            // Al abrir multitarea (swipe up), bloquear para proteger la privacidad visual
            isAppLocked = true

        case .active:
            // Al volver al frente, si está bloqueado y biometría activa, disparar autenticación automática
            if isAppLocked && KeychainVault.shared.isBiometricAuthEnabled && !isAuthenticating {
                triggerBiometricUnlock()
            }

        @unknown default:
            break
        }
    }

    // MARK: - Biometric Authentication Execution

    public func triggerBiometricUnlock(completion: (@MainActor (Bool) -> Void)? = nil) {
        guard KeychainVault.shared.isBiometricAuthEnabled else {
            completion?(false)
            return
        }

        isAuthenticating = true
        KeychainVault.shared.authenticateWithBiometrics(reason: "Desbloquear SmartBot Browser") { [weak self] success in
            guard let self = self else { return }
            self.isAuthenticating = false
            if success {
                HapticManager.shared.notifySuccess()
                withAnimation(LiquidAnimation.interactiveSpring) {
                    self.isAppLocked = false
                }
            }
            completion?(success)
        }
    }

    // MARK: - PIN Verification Execution

    public func verifyPIN(_ pin: String) -> Bool {
        let isCorrect = KeychainVault.shared.verifyAppPIN(pin)
        if isCorrect {
            HapticManager.shared.notifySuccess()
            withAnimation(LiquidAnimation.interactiveSpring) {
                self.isAppLocked = false
            }
            return true
        } else {
            HapticManager.shared.notifyError()
            return false
        }
    }

    // MARK: - Force Manual Lock

    public func lockNow() {
        if KeychainVault.shared.isAppLockEnabled {
            withAnimation(LiquidAnimation.interactiveSpring) {
                self.isAppLocked = true
            }
        }
    }
}
