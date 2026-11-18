import Foundation
import Security
import LocalAuthentication

// MARK: - VaultCredentialEntry Model

public struct VaultCredentialEntry: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var domain: String
    public var username: String
    public var password: String
    public var notes: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        domain: String,
        username: String,
        password: String,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.domain = domain
        self.username = username
        self.password = password
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - KeychainVault (Crash-Proof iOS Keychain Wrapper)

public final class KeychainVault: @unchecked Sendable {
    public static let shared = KeychainVault()

    private let serviceIdentifier = "com.smartbot.browser.keychain"
    private let appPINKey = "smartbot_app_pin_code"
    private let biometricsEnabledKey = "smartbot_biometrics_active"
    private let appLockEnabledKey = "smartbot_app_lock_protection_enabled"
    private let credentialsKey = "smartbot_vault_credentials_payload"

    private init() {}

    // MARK: - 1. App Lock PIN Management (4 Digits)

    @discardableResult
    public func saveAppPIN(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        return saveOrUpdate(key: appPINKey, data: data)
    }

    public func getAppPIN() -> String? {
        guard let data = read(key: appPINKey),
              let pin = String(data: data, encoding: .utf8) else {
            return nil
        }
        return pin
    }

    public func hasAppPIN() -> Bool {
        guard let pin = getAppPIN(), !pin.isEmpty else { return false }
        return true
    }

    public func verifyAppPIN(_ pin: String) -> Bool {
        guard let saved = getAppPIN(), !saved.isEmpty else { return false }
        return saved == pin
    }

    @discardableResult
    public func deleteAppPIN() -> Bool {
        delete(key: appPINKey)
    }

    // Compatibility aliases
    @discardableResult public func savePIN(_ pin: String) -> Bool { saveAppPIN(pin) }
    public func getPIN() -> String? { getAppPIN() }
    public func hasPIN() -> Bool { hasAppPIN() }
    public func verifyPIN(_ input: String) -> Bool { verifyAppPIN(input) }
    @discardableResult public func deletePIN() -> Bool { deleteAppPIN() }

    // MARK: - 2. Persistent Security Preferences

    public var isAppLockEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: appLockEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appLockEnabledKey)
        }
    }

    public var isBiometricAuthEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: biometricsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: biometricsEnabledKey)
        }
    }

    // MARK: - Auto-Lock Preference
    public var autoLockOnBackground: Bool {
        get { UserDefaults.standard.bool(forKey: "smartbot_auto_lock_background") }
        set { UserDefaults.standard.set(newValue, forKey: "smartbot_auto_lock_background") }
    }

    // MARK: - 3. Hardware Biometric Verification

    public var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }

    public var canEvaluateBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var canUseBiometrics: Bool {
        canEvaluateBiometrics
    }

    public func authenticateWithBiometrics(
        reason: String = "Desbloquear SmartBot Browser",
        completion: @escaping @MainActor (Bool) -> Void
    ) {
        let context = LAContext()
        context.localizedCancelTitle = Loc.tr("lock_use_pin")
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            Task { @MainActor in
                completion(false)
            }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            Task { @MainActor in
                completion(success)
            }
        }
    }

    // MARK: - 4. Profile-Specific Passwords

    @discardableResult
    public func saveProfilePassword(profileID: UUID, pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        let key = "profile_pin_\(profileID.uuidString)"
        return saveOrUpdate(key: key, data: data)
    }

    public func verifyProfilePassword(profileID: UUID, pin: String) -> Bool {
        let key = "profile_pin_\(profileID.uuidString)"
        guard let data = read(key: key),
              let stored = String(data: data, encoding: .utf8) else {
            return false
        }
        return stored == pin
    }

    @discardableResult
    public func deleteProfilePassword(profileID: UUID) -> Bool {
        let key = "profile_pin_\(profileID.uuidString)"
        return delete(key: key)
    }

    public func hasProfilePassword(profileID: UUID) -> Bool {
        let key = "profile_pin_\(profileID.uuidString)"
        return read(key: key) != nil
    }

    // MARK: - 5. Password Vault (Credentials Storage)

    public func getAllCredentials() -> [VaultCredentialEntry] {
        guard let data = read(key: credentialsKey),
              let list = try? JSONDecoder().decode([VaultCredentialEntry].self, from: data) else {
            return []
        }
        return list
    }

    @discardableResult
    public func saveCredential(_ entry: VaultCredentialEntry) -> Bool {
        var existing = getAllCredentials()
        if let idx = existing.firstIndex(where: { $0.id == entry.id }) {
            existing[idx] = entry
        } else {
            existing.insert(entry, at: 0)
        }
        guard let data = try? JSONEncoder().encode(existing) else { return false }
        return saveOrUpdate(key: credentialsKey, data: data)
    }

    @discardableResult
    public func deleteCredential(id: UUID) -> Bool {
        var existing = getAllCredentials()
        existing.removeAll(where: { $0.id == id })
        guard let data = try? JSONEncoder().encode(existing) else { return false }
        return saveOrUpdate(key: credentialsKey, data: data)
    }

    // MARK: - 6. Password Generator

    public func generateSecurePassword(length: Int = 16, includeSymbols: Bool = true) -> String {
        let letters = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
        let digits = "23456789"
        let symbols = "!@#$%^&*-_=+?"

        var characterPool = letters + digits
        if includeSymbols {
            characterPool += symbols
        }

        var result = ""
        for _ in 0..<length {
            if let randChar = characterPool.randomElement() {
                result.append(randChar)
            }
        }
        return result
    }

    // MARK: - 7. Factory Reset (Secure Wipe)

    @discardableResult
    public func wipeAllSecureData() -> Bool {
        deleteAppPIN()
        _ = delete(key: credentialsKey)
        UserDefaults.standard.removeObject(forKey: biometricsEnabledKey)
        UserDefaults.standard.removeObject(forKey: appLockEnabledKey)
        return true
    }

    // MARK: - Internal Safe Keychain CRUD Operations

    private func saveOrUpdate(key: String, data: Data) -> Bool {
        if read(key: key) != nil {
            if update(key: key, data: data) {
                return true
            }
            return create(key: key, data: data)
        } else {
            if create(key: key, data: data) {
                return true
            }
            return update(key: key, data: data)
        }
    }

    private func create(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func read(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return data
    }

    private func update(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }

    @discardableResult
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Compatibility Aliases
public typealias KeychainSecurityHelper = KeychainVault
public typealias VaultCredential = VaultCredentialEntry
