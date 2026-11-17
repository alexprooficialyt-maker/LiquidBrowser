import SwiftUI
import UIKit

public final class HapticManager: @unchecked Sendable {
    public static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        prepare()
    }

    public func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
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

    public func touchRigid() {
        rigidImpact.impactOccurred(intensity: 0.9)
    }

    public func selectionChanged() {
        selectionFeedback.selectionChanged()
    }

    public func notifySuccess() {
        notificationFeedback.notificationOccurred(.success)
    }

    public func notifyWarning() {
        notificationFeedback.notificationOccurred(.warning)
    }

    public func notifyError() {
        notificationFeedback.notificationOccurred(.error)
    }
}
