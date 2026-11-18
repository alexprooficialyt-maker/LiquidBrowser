import SwiftUI
import LocalAuthentication
import UIKit

// MARK: - DeviceHardwareDetector

public struct DeviceHardwareDetector: Sendable {
    public static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    public static var friendlyDeviceName: String {
        let id = modelIdentifier
        switch id {
        // iPhone 16 Family
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"

        // iPhone 15 Family
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"

        // iPhone 14 Family
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"

        // iPhone 13 Family
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"

        // iPhone SE
        case "iPhone14,6": return "iPhone SE (3rd generation)"
        case "iPhone12,8": return "iPhone SE (2nd generation)"

        // Simulators
        case "i386", "x86_64", "arm64":
            return UIDevice.current.name.contains("iPad") ? "iPad (Simulador)" : "iPhone (Simulador)"

        default:
            if id.hasPrefix("iPad") {
                return "iPad"
            }
            return UIDevice.current.name
        }
    }

    public static var hasDynamicIsland: Bool {
        let id = modelIdentifier
        return id.hasPrefix("iPhone15,2") ||
               id.hasPrefix("iPhone15,3") ||
               id.hasPrefix("iPhone16,") ||
               id.hasPrefix("iPhone17,")
    }
}

// MARK: - DeviceBiometryHelper (@MainActor Unified Biometrics & Security Helper)

@MainActor
public final class DeviceBiometryHelper: Sendable {
    nonisolated(unsafe) public static let shared = DeviceBiometryHelper()

    private init() {}

    // MARK: - Hardware Biometry Capabilities

    public var biometryType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }

    public var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometryName: String {
        switch biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "PIN"
        }
    }

    public var unlockPromptTitle: String {
        switch biometryType {
        case .faceID:
            return Loc.tr("lock_use_faceid")
        case .touchID:
            return Loc.tr("lock_use_touchid")
        default:
            return Loc.tr("lock_use_pin")
        }
    }

    public var biometryIconType: LiquidIconType {
        switch biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .pinPad
        }
    }

    // MARK: - Auto-Scan Face ID / Touch ID (0.25s Delay)

    public func scheduleAutoScan(
        delaySeconds: Double = 0.25,
        reason: String = "Desbloquear SmartBot Browser",
        completion: @escaping @MainActor (Bool) -> Void
    ) {
        guard isBiometricsAvailable else {
            completion(false)
            return
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            self.authenticate(reason: reason, completion: completion)
        }
    }

    // MARK: - Real Hardware Authentication Execution

    @MainActor
    public func authenticate(reason: String = "Desbloquear SmartBot Browser") async -> Bool {
        await withCheckedContinuation { continuation in
            authenticate(reason: reason) { success in
                continuation.resume(returning: success)
            }
        }
    }

    // MARK: - Enable Biometrics Helper

    @MainActor
    public func tryEnableBiometrics() async -> (success: Bool, errorMessage: String?) {
        guard isBiometricsAvailable else {
            return (false, "Este dispositivo no es compatible con biometría.")
        }
        let result = await authenticate(reason: "Verificar identidad para activar Face ID / Touch ID")
        return (result, result ? nil : "No se pudo verificar la identidad. Inténtalo de nuevo.")
    }

    public func authenticate(
        reason: String = "Desbloquear SmartBot Browser",
        completion: @escaping @MainActor (Bool) -> Void
    ) {
        let context = LAContext()
        context.localizedCancelTitle = Loc.tr("lock_use_pin")
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            Task { @MainActor in
                completion(success)
            }
        }
    }
}
