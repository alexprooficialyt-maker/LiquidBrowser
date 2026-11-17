import UIKit

// MARK: - Apple Haptic Engine Manager

@MainActor
public final class HapticManager: Sendable {
    public static let shared = HapticManager()

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    public func prepare() {
        selectionGenerator.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        softImpact.prepare()
        rigidImpact.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Discrete Feedbacks

    public func touchSelection() {
        selectionGenerator.selectionChanged()
    }

    public func touchLight() {
        lightImpact.impactOccurred(intensity: 0.75)
    }

    public func touchMedium() {
        mediumImpact.impactOccurred(intensity: 0.85)
    }

    public func touchHeavy() {
        heavyImpact.impactOccurred(intensity: 1.0)
    }

    public func touchSoft() {
        softImpact.impactOccurred(intensity: 0.65)
    }

    public func touchRigid() {
        rigidImpact.impactOccurred(intensity: 0.90)
    }

    // MARK: - Notifications

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
