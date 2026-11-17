import SwiftUI

// MARK: - LiquidGlassConfig

public struct LiquidGlassConfig: Sendable {
    public var cornerRadius: CGFloat
    public var material: Material
    public var strokeWidth: CGFloat
    public var shadowRadius: CGFloat
    public var shadowY: CGFloat
    public var opacity: Double

    public init(
        cornerRadius: CGFloat = 19,
        material: Material = .ultraThinMaterial,
        strokeWidth: CGFloat = 0.5,
        shadowRadius: CGFloat = 16,
        shadowY: CGFloat = 6,
        opacity: Double = 1.0
    ) {
        self.cornerRadius = cornerRadius
        self.material = material
        self.strokeWidth = strokeWidth
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.opacity = opacity
    }

    // Configuración Óptima: Radio equilibrado 19pt continuo, no píldora extrema
    public static let capsuleBar = LiquidGlassConfig(
        cornerRadius: 19,
        material: .ultraThinMaterial,
        strokeWidth: 0.5,
        shadowRadius: 16,
        shadowY: 6
    )

    public static let card = LiquidGlassConfig(
        cornerRadius: 18,
        material: .thinMaterial,
        strokeWidth: 0.5,
        shadowRadius: 12,
        shadowY: 4
    )

    public static let chip = LiquidGlassConfig(
        cornerRadius: 14,
        material: .ultraThinMaterial,
        strokeWidth: 0.5,
        shadowRadius: 6,
        shadowY: 2
    )

    public static let sheet = LiquidGlassConfig(
        cornerRadius: 24,
        material: .ultraThinMaterial,
        strokeWidth: 0.5,
        shadowRadius: 24,
        shadowY: 10
    )
}

// MARK: - LiquidGlassContainer

public struct LiquidGlassContainer: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var config: LiquidGlassConfig

    public init(config: LiquidGlassConfig = .capsuleBar) {
        self.config = config
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
        let theme = ThemeManager.shared

        content
            .background {
                shape
                    .fill(config.material)
                    .overlay {
                        shape
                            .fill(theme.glassMaterialFill(for: colorScheme))
                    }
            }
            .overlay {
                shape
                    .strokeBorder(
                        theme.borderSpecular(for: colorScheme),
                        lineWidth: config.strokeWidth
                    )
            }
            .shadow(
                color: theme.shadowColor(for: colorScheme),
                radius: config.shadowRadius,
                x: 0,
                y: config.shadowY
            )
            .opacity(config.opacity)
    }
}

// MARK: - View Extension

extension View {
    public func liquidGlass(config: LiquidGlassConfig = .capsuleBar) -> some View {
        modifier(LiquidGlassContainer(config: config))
    }
}
