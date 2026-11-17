import SwiftUI

// MARK: - Apple-Grade Spring Physics Curves

public struct LiquidAnimation {
    /// Resorte altamente responsivo para botones y cápsulas táctiles
    public static let interactiveSpring = Animation.spring(response: 0.32, dampingFraction: 0.82)

    /// Resorte suave para paneles, modales y navegación entre pestañas
    public static let smoothSpring = Animation.spring(response: 0.44, dampingFraction: 0.84)
    public static let gentleSpring = Animation.spring(response: 0.45, dampingFraction: 0.88)

    /// Resorte elástico rápido para feedback táctil y badges numéricos
    public static let snappySpring = Animation.spring(response: 0.24, dampingFraction: 0.76)
    public static let bouncySpring = Animation.spring(response: 0.38, dampingFraction: 0.62)

    /// Curva cinemática para entrada de títulos, onboarding y bienvenida
    public static let cinematicEntrance = Animation.spring(response: 0.60, dampingFraction: 0.88)

    /// Curvas de transición para progreso y hojas modales
    public static let progressEase = Animation.easeInOut(duration: 0.22)
    public static let sheetTransition = Animation.spring(response: 0.38, dampingFraction: 0.86)
}

// MARK: - PressableFeedbackModifier

public struct PressableFeedbackModifier: ViewModifier {
    @State private var isPressed: Bool = false

    public init() {}

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(LiquidAnimation.snappySpring, value: isPressed)
            ._onButtonGesture { pressing in
                if pressing {
                    HapticManager.shared.touchLight()
                }
                isPressed = pressing
            } perform: {}
    }
}

extension View {
    public func pressableFeedback() -> some View {
        modifier(PressableFeedbackModifier())
    }
}
