import SwiftUI

// MARK: - AppThemeMode

public enum AppThemeMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: return Loc.tr("onboarding_theme_system")
        case .light:  return Loc.tr("onboarding_theme_light")
        case .dark:   return Loc.tr("onboarding_theme_dark")
        }
    }

    public var displayName: String {
        title
    }

    public var description: String {
        switch self {
        case .system: return Loc.tr("onboarding_theme_system_desc")
        case .light:  return Loc.tr("onboarding_theme_light_desc")
        case .dark:   return Loc.tr("onboarding_theme_dark_desc")
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - ProfileAccentColor Palette (8 Apple-Grade Accents)

public enum ProfileAccentColor: String, CaseIterable, Identifiable, Codable, Sendable {
    case monochrome = "monochrome"
    case titanium   = "titanium"
    case graphite   = "graphite"
    case sapphire   = "sapphire"
    case emerald    = "emerald"
    case ruby       = "ruby"
    case amethyst   = "amethyst"
    case amber      = "amber"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .monochrome: return "Monocromo Puro"
        case .titanium:   return "Titanio Natural"
        case .graphite:   return "Grafito Espacial"
        case .sapphire:   return "Zafiro Azul"
        case .emerald:    return "Esmeralda"
        case .ruby:       return "Rubí Profundo"
        case .amethyst:   return "Amatista"
        case .amber:      return "Ámbar Radiante"
        }
    }

    public func color(for scheme: ColorScheme) -> Color {
        switch self {
        case .monochrome:
            return scheme == .dark ? Color.white : Color.black
        case .titanium:
            return scheme == .dark ? Color(red: 0.90, green: 0.90, blue: 0.92) : Color(red: 0.22, green: 0.22, blue: 0.24)
        case .graphite:
            return scheme == .dark ? Color(red: 0.70, green: 0.72, blue: 0.75) : Color(red: 0.28, green: 0.30, blue: 0.33)
        case .sapphire:
            return Color(red: 0.04, green: 0.52, blue: 1.00)
        case .emerald:
            return Color(red: 0.204, green: 0.780, blue: 0.349)
        case .ruby:
            return Color(red: 1.00, green: 0.23, blue: 0.30)
        case .amethyst:
            return Color(red: 0.70, green: 0.35, blue: 0.90)
        case .amber:
            return Color(red: 1.00, green: 0.65, blue: 0.05)
        }
    }

    public var swatchColor: Color {
        switch self {
        case .monochrome: return Color(white: 0.55)
        case .titanium:   return Color(red: 0.68, green: 0.68, blue: 0.70)
        case .graphite:   return Color(red: 0.38, green: 0.40, blue: 0.44)
        case .sapphire:   return Color(red: 0.04, green: 0.52, blue: 1.00)
        case .emerald:    return Color(red: 0.204, green: 0.780, blue: 0.349)
        case .ruby:       return Color(red: 1.00, green: 0.23, blue: 0.30)
        case .amethyst:   return Color(red: 0.70, green: 0.35, blue: 0.90)
        case .amber:      return Color(red: 1.00, green: 0.65, blue: 0.05)
        }
    }
}

// MARK: - ProfileColorCircleView (Professional 36x36 Apple Color Swatch)

public struct ProfileColorCircleView: View {
    public let accent: ProfileAccentColor
    public let isSelected: Bool
    public var size: CGFloat = 36
    public var onSelect: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(
        accent: ProfileAccentColor,
        isSelected: Bool,
        size: CGFloat = 36,
        onSelect: @escaping () -> Void = {}
    ) {
        self.accent = accent
        self.isSelected = isSelected
        self.size = size
        self.onSelect = onSelect
    }

    public init(
        color: ProfileAccentColor,
        isSelected: Bool,
        size: CGFloat = 36,
        onSelect: @escaping () -> Void = {}
    ) {
        self.accent = color
        self.isSelected = isSelected
        self.size = size
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.touchLight()
            onSelect()
        }) {
            ZStack {
                // Anillo de selección exterior con resorte
                if isSelected {
                    Circle()
                        .strokeBorder(
                            colorScheme == .dark ? Color.white : Color.black,
                            lineWidth: 2.5
                        )
                        .frame(width: size + 8, height: size + 8)
                        .transition(.scale.combined(with: .opacity))
                }

                // Círculo de color principal sólido
                Circle()
                    .fill(accent.swatchColor)
                    .frame(width: size, height: size)
                    .shadow(
                        color: accent.swatchColor.opacity(isSelected ? 0.45 : 0.20),
                        radius: isSelected ? 8 : 4,
                        y: isSelected ? 3 : 2
                    )

                // Borde especular fino de acabado Apple
                Circle()
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5)
                    .frame(width: size, height: size)
            }
            .frame(width: size + 10, height: size + 10)
            .animation(LiquidAnimation.snappySpring, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ThemeManager (@Observable Single Source of Truth)

@Observable
public final class ThemeManager: @unchecked Sendable {
    public static let shared = ThemeManager()

    public var currentMode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "smartbot_theme_mode")
        }
    }

    public var defaultAccent: ProfileAccentColor {
        didSet {
            UserDefaults.standard.set(defaultAccent.rawValue, forKey: "smartbot_theme_accent")
        }
    }

    // Apple Official Green (#34C759)
    public let appleGreen = Color(red: 0.204, green: 0.780, blue: 0.349)

    public init() {
        let storedMode = UserDefaults.standard.string(forKey: "smartbot_theme_mode") ?? AppThemeMode.system.rawValue
        self.currentMode = AppThemeMode(rawValue: storedMode) ?? .system

        let storedAccent = UserDefaults.standard.string(forKey: "smartbot_theme_accent") ?? ProfileAccentColor.monochrome.rawValue
        self.defaultAccent = ProfileAccentColor(rawValue: storedAccent) ?? .monochrome
    }

    // MARK: - ColorScheme Resolution

    public var preferredColorScheme: ColorScheme? {
        currentMode.colorScheme
    }

    public func effectiveScheme(systemScheme: ColorScheme) -> ColorScheme {
        currentMode.colorScheme ?? systemScheme
    }

    // MARK: - Apple Liquid Glass & Monochrome Palette

    public func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.99)
    }

    public func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.09) : Color.white
    }

    public func surfaceElevated(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.14) : Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    public func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.11) : Color.white
    }

    public func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }

    public func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.65) : Color(white: 0.40)
    }

    public func textTertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.40) : Color(white: 0.65)
    }

    public func accent(for scheme: ColorScheme) -> Color {
        defaultAccent.color(for: scheme)
    }

    public func glassMaterialFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.72)
    }

    public func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black.opacity(0.65) : Color.black.opacity(0.08)
    }

    public func specularBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.10)
    }

    public func borderSpecular(for scheme: ColorScheme) -> LinearGradient {
        if scheme == .dark {
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.38), location: 0.0),
                    .init(color: Color.white.opacity(0.12), location: 0.45),
                    .init(color: Color.white.opacity(0.04), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.95), location: 0.0),
                    .init(color: Color.black.opacity(0.06), location: 0.50),
                    .init(color: Color.black.opacity(0.14), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Global View Extension for Green Tint

extension View {
    public func smartBotGlobalTint() -> some View {
        self.tint(ThemeManager.shared.appleGreen)
    }
}

// MARK: - Compatibility Alias
public typealias ThemeEngine = ThemeManager
public typealias MonochromeAccentTone = ProfileAccentColor

// MARK: - Color Hex Initializer Extension
extension Color {
    public init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
