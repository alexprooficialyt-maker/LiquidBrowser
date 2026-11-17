import SwiftUI

public struct LiquidGlassConfig {
    public var cornerRadius: CGFloat
    public var material: Material
    public var specularWidth: CGFloat
    public var shadowRadius: CGFloat
    public var shadowY: CGFloat
    public var shadowOpacity: Double

    public init(
        cornerRadius: CGFloat = 19,
        material: Material = .ultraThinMaterial,
        specularWidth: CGFloat = 0.5,
        shadowRadius: CGFloat = 16,
        shadowY: CGFloat = 6,
        shadowOpacity: Double = 0.35
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.specularWidth = specularWidth
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.shadowOpacity = shadowOpacity
    }

    public static let capsuleBar = LiquidGlassConfig(
        cornerRadius: 19,
        material: .ultraThinMaterial,
        specularWidth: 0.5,
        shadowRadius: 18,
        shadowY: 7,
        shadowOpacity: 0.38
    )

    public static let card = LiquidGlassConfig(
        cornerRadius: 16,
        material: .thinMaterial,
        specularWidth: 0.5,
        shadowRadius: 10,
        shadowY: 4,
        shadowOpacity: 0.22
    )

    public static let chip = LiquidGlassConfig(
        cornerRadius: 12,
        material: .ultraThinMaterial,
        specularWidth: 0.5,
        shadowRadius: 6,
        shadowY: 2,
        shadowOpacity: 0.15
    )

    public static let dialog = LiquidGlassConfig(
        cornerRadius: 24,
        material: .regularMaterial,
        specularWidth: 0.6,
        shadowRadius: 28,
        shadowY: 12,
        shadowOpacity: 0.45
    )
}

public struct LiquidGlassContainer: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var config: LiquidGlassConfig

    public func body(content: Content) -> some View {
        let theme = ThemeEngine.shared
        let shape = RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)

        content
            .background {
                ZStack {
                    shape
                        .fill(config.material)

                    shape
                        .fill(theme.glassMaterialFill(for: colorScheme))

                    if colorScheme == .dark {
                        shape
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.04), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            }
            .clipShape(shape)
            .overlay {
                shape
                    .strokeBorder(
                        theme.borderSpecular(for: colorScheme),
                        lineWidth: config.specularWidth
                    )
            }
            .shadow(
                color: theme.shadowColor(for: colorScheme).opacity(config.shadowOpacity),
                radius: config.shadowRadius,
                x: 0,
                y: config.shadowY
            )
    }
}

public struct LiquidMonochromeBadge: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var isHighlighted: Bool

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        content
            .foregroundStyle(isHighlighted ? (colorScheme == .dark ? Color.black : Color.white) : (colorScheme == .dark ? Color.white : Color.black))
            .background {
                shape.fill(
                    isHighlighted ? (colorScheme == .dark ? Color.white : Color.black) : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08))
                )
            }
            .overlay {
                if !isHighlighted {
                    shape.strokeBorder(
                        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.12),
                        lineWidth: 0.5
                    )
                }
            }
    }
}

extension View {
    public func liquidGlass(config: LiquidGlassConfig = .capsuleBar) -> some View {
        modifier(LiquidGlassContainer(config: config))
    }

    public func liquidGlassCustom(cornerRadius: CGFloat, material: Material = .ultraThinMaterial) -> some View {
        modifier(LiquidGlassContainer(config: LiquidGlassConfig(cornerRadius: cornerRadius, material: material)))
    }

    public func monochromeBadge(isHighlighted: Bool = false) -> some View {
        modifier(LiquidMonochromeBadge(isHighlighted: isHighlighted))
    }
}
