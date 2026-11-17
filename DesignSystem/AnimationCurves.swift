import SwiftUI

// MARK: - LiquidAnimation

public struct LiquidAnimation {
    public static let interactiveSpring = Animation.spring(response: 0.32, dampingFraction: 0.82)
    public static let gentleSpring = Animation.spring(response: 0.45, dampingFraction: 0.88)
    public static let snappySpring = Animation.spring(response: 0.24, dampingFraction: 0.76)
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
