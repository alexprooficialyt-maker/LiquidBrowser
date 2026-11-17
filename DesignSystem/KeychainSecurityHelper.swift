import Foundation
import Security
import LocalAuthentication

// MARK: - KeychainSecurityHelper

public final class KeychainSecurityHelper: @unchecked Sendable {
    public static let shared = KeychainSecurityHelper()

    private let serviceName = "com.liquidbrowser.app.security"
    private let pinAccountKey = "user_app_pin_v1"
    private let biometricAccountKey = "biometric_auth_enabled_v1"
    private let appLockEnabledKey = "app_lock_protection_enabled_v1"

    private init() {}

    // MARK: - PIN Operations

    @discardableResult
    public func savePIN(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        deletePIN()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: pinAccountKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func getPIN() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: pinAccountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    public func deletePIN() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: pinAccountKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    public func hasPIN() -> Bool {
        guard let pin = getPIN(), !pin.isEmpty else { return false }
        return true
    }

    public func verifyPIN(_ input: String) -> Bool {
        guard let stored = getPIN() else { return false }
        return stored == input
    }

    // MARK: - App Lock Active State

    public var isAppLockEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: appLockEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appLockEnabledKey)
        }
    }

    // MARK: - Biometrics State

    public var isBiometricAuthEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: biometricAccountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: biometricAccountKey)
        }
    }

    public var canEvaluateBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }

    public func authenticateWithBiometrics(reason: String = "Desbloquear LiquidBrowser", completion: @escaping @Sendable (Bool) -> Void) {
        let context = LAContext()
        context.localizedCancelTitle = "Usar PIN"
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
