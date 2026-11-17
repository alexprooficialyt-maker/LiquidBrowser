import SwiftUI

// MARK: - AppThemeMode

public enum AppThemeMode: String, CaseIterable, Codable, Sendable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    public var title: String {
        switch self {
        case .system: return Loc.tr("onboarding_theme_system")
        case .light:  return Loc.tr("onboarding_theme_light")
        case .dark:   return Loc.tr("onboarding_theme_dark")
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

// MARK: - ProfileAccentColor Palette

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
            return scheme == .dark ? Color(red: 0.90, green: 0.90, blue: 0.92) : Color(red: 0.18, green: 0.18, blue: 0.20)
        case .graphite:
            return scheme == .dark ? Color(red: 0.70, green: 0.72, blue: 0.75) : Color(red: 0.28, green: 0.30, blue: 0.33)
        case .sapphire:
            return Color(red: 0.04, green: 0.48, blue: 0.98)
        case .emerald:
            return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .ruby:
            return Color(red: 0.98, green: 0.22, blue: 0.28)
        case .amethyst:
            return Color(red: 0.69, green: 0.32, blue: 0.87)
        case .amber:
            return Color(red: 1.00, green: 0.62, blue: 0.04)
        }
    }

    public var swatchColor: Color {
        switch self {
        case .monochrome: return Color.gray
        case .titanium:   return Color(red: 0.65, green: 0.65, blue: 0.68)
        case .graphite:   return Color(red: 0.45, green: 0.45, blue: 0.48)
        case .sapphire:   return Color(red: 0.04, green: 0.48, blue: 0.98)
        case .emerald:    return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .ruby:       return Color(red: 0.98, green: 0.22, blue: 0.28)
        case .amethyst:   return Color(red: 0.69, green: 0.32, blue: 0.87)
        case .amber:      return Color(red: 1.00, green: 0.62, blue: 0.04)
        }
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

// MARK: - Compatibility Alias
public typealias ThemeEngine = ThemeManager
public typealias MonochromeAccentTone = ProfileAccentColor
