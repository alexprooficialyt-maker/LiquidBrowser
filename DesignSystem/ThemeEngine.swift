import SwiftUI

// MARK: - AppThemeMode

public enum AppThemeMode: String, CaseIterable, Codable, Sendable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var title: String {
        switch self {
        case .system: return "Automático (Sistema)"
        case .light:  return "Modo Claro Blanco"
        case .dark:   return "Modo Oscuro Negro"
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

// MARK: - MonochromeAccentTone

public enum MonochromeAccentTone: String, CaseIterable, Codable, Sendable {
    case monochrome = "monochrome"
    case titanium   = "titanium"
    case graphite   = "graphite"
    case silver     = "silver"

    public var displayName: String {
        switch self {
        case .monochrome: return "Monocromo Puro"
        case .titanium:   return "Titanio Natural"
        case .graphite:   return "Grafito Oscuro"
        case .silver:     return "Plata Líquida"
        }
    }

    public func tint(for scheme: ColorScheme) -> Color {
        switch self {
        case .monochrome:
            return scheme == .dark ? Color.white : Color.black
        case .titanium:
            return scheme == .dark ? Color(red: 0.90, green: 0.90, blue: 0.92) : Color(red: 0.16, green: 0.16, blue: 0.18)
        case .graphite:
            return scheme == .dark ? Color(red: 0.82, green: 0.82, blue: 0.85) : Color(red: 0.22, green: 0.22, blue: 0.25)
        case .silver:
            return scheme == .dark ? Color(red: 0.75, green: 0.75, blue: 0.78) : Color(red: 0.35, green: 0.35, blue: 0.38)
        }
    }
}

// MARK: - ThemeManager (@Observable Single Source of Truth)

@Observable
public final class ThemeManager: @unchecked Sendable {
    public static let shared = ThemeManager()

    public var currentMode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "app_theme_mode")
        }
    }

    public var accentTone: MonochromeAccentTone {
        didSet {
            UserDefaults.standard.set(accentTone.rawValue, forKey: "app_monochrome_accent_tone")
        }
    }

    public init() {
        let storedMode = UserDefaults.standard.string(forKey: "app_theme_mode") ?? AppThemeMode.system.rawValue
        self.currentMode = AppThemeMode(rawValue: storedMode) ?? .system

        let storedAccent = UserDefaults.standard.string(forKey: "app_monochrome_accent_tone") ?? MonochromeAccentTone.titanium.rawValue
        self.accentTone = MonochromeAccentTone(rawValue: storedAccent) ?? .titanium
    }

    // MARK: - ColorScheme Resolution

    public var preferredColorScheme: ColorScheme? {
        currentMode.colorScheme
    }

    public func effectiveScheme(systemScheme: ColorScheme) -> ColorScheme {
        currentMode.colorScheme ?? systemScheme
    }

    // MARK: - Paleta Monocroma Estricta (Blanco, Negro, Cristal)

    public func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black : Color(red: 0.985, green: 0.985, blue: 0.990)
    }

    public func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.09) : Color.white
    }

    public func surfaceElevated(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.13, green: 0.13, blue: 0.15) : Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    public func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.12) : Color.white
    }

    public func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }

    public func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.65) : Color(white: 0.40)
    }

    public func textTertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.42) : Color(white: 0.62)
    }

    public func accent(for scheme: ColorScheme) -> Color {
        accentTone.tint(for: scheme)
    }

    public func progressHighlight(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }

    public func glassMaterialFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.70)
    }

    public func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black.opacity(0.60) : Color.black.opacity(0.09)
    }

    public func specularBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.11)
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

// MARK: - Compatibility Alias for Existing Code

public typealias ThemeEngine = ThemeManager
