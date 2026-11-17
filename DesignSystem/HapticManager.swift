import UIKit

// MARK: - HapticManager

public final class HapticManager: @unchecked Sendable {
    public static let shared = HapticManager()

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    public func prepare() {
        selectionGenerator.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationGenerator.prepare()
    }

    public func touchLight() {
        lightImpact.impactOccurred()
    }

    public func touchMedium() {
        mediumImpact.impactOccurred()
    }

    public func touchHeavy() {
        heavyImpact.impactOccurred()
    }

    public func touchRigid() {
        rigidImpact.impactOccurred()
    }

    public func touchSoft() {
        softImpact.impactOccurred()
    }

    public func selectionChanged() {
        selectionGenerator.selectionChanged()
    }

    public func notifySuccess() {
        notificationGenerator.notificationOccurred(.success)
    }

    public func notifyWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    public func notifyError() {
        notificationGenerator.notificationOccurred(.error)
    }
}
