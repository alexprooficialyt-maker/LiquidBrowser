import SwiftUI

public enum LiquidAnimation {
    public static let interactiveSpring: Animation = .spring(response: 0.32, dampingFraction: 0.82, blendDuration: 0)
    public static let standardSpring: Animation = .spring(response: 0.44, dampingFraction: 0.86, blendDuration: 0)
    public static let gentleSpring: Animation = .spring(response: 0.58, dampingFraction: 0.90, blendDuration: 0)
    public static let snappySpring: Animation = .spring(response: 0.24, dampingFraction: 0.76, blendDuration: 0)

    public static let tabTransition: Animation = .spring(response: 0.36, dampingFraction: 0.84)
    public static let panelSlide: Animation = .spring(response: 0.40, dampingFraction: 0.88)
    public static let crossFade: Animation = .easeInOut(duration: 0.22)
    public static let progressEase: Animation = .linear(duration: 0.18)
}

public struct PressableScaleModifier: ViewModifier {
    @State private var isPressed: Bool = false
    public var scale: CGFloat = 0.95
    public var action: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(LiquidAnimation.snappySpring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            HapticManager.shared.touchLight()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action?()
                    }
            )
    }
}

extension View {
    public func pressableFeedback(scale: CGFloat = 0.95, perform action: (() -> Void)? = nil) -> some View {
        modifier(PressableScaleModifier(scale: scale, action: action))
    }
}
