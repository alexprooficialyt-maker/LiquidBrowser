import SwiftUI

public struct LiquidButtonModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var isHighlighted: Bool
    public var customRadius: CGFloat
    public var customPadding: EdgeInsets

    public init(
        isHighlighted: Bool = false,
        customRadius: CGFloat = 16,
        customPadding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    ) {
        self.isHighlighted = isHighlighted
        self.customRadius = customRadius
        self.customPadding = customPadding
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: customRadius, style: .continuous)
        let theme = ThemeEngine.shared

        content
            .padding(customPadding)
            .background {
                if isHighlighted {
                    shape.fill(colorScheme == .dark ? Color.white : Color.black)
                } else {
                    shape.fill(theme.glassMaterialFill(for: colorScheme))
                }
            }
            .overlay {
                shape.strokeBorder(
                    theme.borderSpecular(for: colorScheme),
                    lineWidth: 0.5
                )
            }
            .foregroundStyle(
                isHighlighted ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme)
            )
            .pressableFeedback()
    }
}

public struct LiquidIconButton: View {
    public var type: LiquidIconType
    public var size: CGFloat
    public var iconSize: CGFloat
    public var isHighlighted: Bool
    public var cornerRadius: CGFloat
    public var action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ type: LiquidIconType,
        size: CGFloat = 40,
        iconSize: CGFloat = 18,
        isHighlighted: Bool = false,
        cornerRadius: CGFloat = 14,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.size = size
        self.iconSize = iconSize
        self.isHighlighted = isHighlighted
        self.cornerRadius = cornerRadius
        self.action = action
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let theme = ThemeEngine.shared

        Button(action: {
            HapticManager.shared.touchLight()
            action()
        }) {
            ZStack {
                shape.fill(
                    isHighlighted ? (colorScheme == .dark ? Color.white : Color.black) : theme.glassMaterialFill(for: colorScheme)
                )

                LiquidIconView(
                    type,
                    size: iconSize,
                    color: isHighlighted ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme),
                    strokeWidth: 1.5
                )
            }
            .frame(width: size, height: size)
            .overlay {
                shape.strokeBorder(
                    theme.borderSpecular(for: colorScheme),
                    lineWidth: 0.5
                )
            }
            .clipShape(shape)
        }
        .buttonStyle(.plain)
        .pressableFeedback()
    }
}

extension View {
    public func liquidButton(
        isHighlighted: Bool = false,
        customRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    ) -> some View {
        modifier(LiquidButtonModifier(isHighlighted: isHighlighted, customRadius: customRadius, customPadding: padding))
    }
}
