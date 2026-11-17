import SwiftUI

// MARK: - Liquid Glass Card Modifier

public struct LiquidGlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var cornerRadius: CGFloat = 20

    public init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let theme = ThemeManager.shared

        content
            .background {
                ZStack {
                    shape
                        .fill(.ultraThinMaterial)

                    shape
                        .fill(theme.glassMaterialFill(for: colorScheme))

                    shape
                        .strokeBorder(theme.borderSpecular(for: colorScheme), lineWidth: 0.5)
                }
            }
            .clipShape(shape)
            .shadow(
                color: theme.shadowColor(for: colorScheme),
                radius: colorScheme == .dark ? 16 : 10,
                x: 0,
                y: colorScheme == .dark ? 6 : 4
            )
    }
}

// MARK: - Liquid Glass Capsule Modifier (Para Barra de Búsqueda Apple Safari)

public struct LiquidGlassCapsuleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var cornerRadius: CGFloat = 16

    public init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let theme = ThemeManager.shared

        content
            .background {
                ZStack {
                    shape
                        .fill(.ultraThinMaterial)

                    shape
                        .fill(theme.glassMaterialFill(for: colorScheme))

                    shape
                        .strokeBorder(theme.borderSpecular(for: colorScheme), lineWidth: 0.5)
                }
            }
            .clipShape(shape)
            .shadow(
                color: theme.shadowColor(for: colorScheme),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Liquid Glass Specular Hairline Modifier

public struct LiquidSpecularHighlightModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public var cornerRadius: CGFloat = 16
    public var lineWidth: CGFloat = 0.5

    public init(cornerRadius: CGFloat = 16, lineWidth: CGFloat = 0.5) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let theme = ThemeManager.shared

        content
            .overlay {
                shape.strokeBorder(theme.borderSpecular(for: colorScheme), lineWidth: lineWidth)
            }
    }
}

// MARK: - View Extensions for Liquid Glass

extension View {
    public func liquidGlassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius))
    }

    public func liquidGlassCapsule(cornerRadius: CGFloat = 16) -> some View {
        modifier(LiquidGlassCapsuleModifier(cornerRadius: cornerRadius))
    }

    public func liquidSpecularHighlight(cornerRadius: CGFloat = 16, lineWidth: CGFloat = 0.5) -> some View {
        modifier(LiquidSpecularHighlightModifier(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}
