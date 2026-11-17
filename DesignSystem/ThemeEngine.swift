import SwiftUI

public enum ColorSchemePreference: String, CaseIterable, Codable, Sendable {
    case system = "Sistema"
    case light = "Claro"
    case dark = "Oscuro"
}

public enum AccentMonochrome: String, CaseIterable, Codable, Sendable {
    case monochrome = "Monocromo"
    case titanium = "Titanio"
    case graphite = "Grafito"
    case silver = "Plata"

    public var lightTint: Color {
        switch self {
        case .monochrome: return Color.black
        case .titanium:   return Color(red: 0.15, green: 0.15, blue: 0.17)
        case .graphite:   return Color(red: 0.22, green: 0.22, blue: 0.25)
        case .silver:     return Color(red: 0.35, green: 0.35, blue: 0.38)
        }
    }

    public var darkTint: Color {
        switch self {
        case .monochrome: return Color.white
        case .titanium:   return Color(red: 0.90, green: 0.90, blue: 0.92)
        case .graphite:   return Color(red: 0.82, green: 0.82, blue: 0.85)
        case .silver:     return Color(red: 0.75, green: 0.75, blue: 0.78)
        }
    }
}

@Observable
public final class ThemeEngine: @unchecked Sendable {
    public static let shared = ThemeEngine()

    public var preference: ColorSchemePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: "theme_preference")
        }
    }

    public var accentVariant: AccentMonochrome {
        didSet {
            UserDefaults.standard.set(accentVariant.rawValue, forKey: "theme_accent_monochrome")
        }
    }

    public init() {
        let storedPref = UserDefaults.standard.string(forKey: "theme_preference") ?? ColorSchemePreference.system.rawValue
        self.preference = ColorSchemePreference(rawValue: storedPref) ?? .system

        let storedAccent = UserDefaults.standard.string(forKey: "theme_accent_monochrome") ?? AccentMonochrome.monochrome.rawValue
        self.accentVariant = AccentMonochrome(rawValue: storedAccent) ?? .monochrome
    }

    public func effectiveScheme(systemScheme: ColorScheme) -> ColorScheme {
        switch preference {
        case .system: return systemScheme
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    public func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.99)
    }

    public func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.09) : Color.white
    }

    public func surfaceElevated(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.14) : Color(red: 0.95, green: 0.95, blue: 0.96)
    }

    public func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }

    public func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.65) : Color(white: 0.38)
    }

    public func textTertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.40) : Color(white: 0.60)
    }

    public func borderSpecular(for scheme: ColorScheme) -> LinearGradient {
        if scheme == .dark {
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.35), location: 0.0),
                    .init(color: Color.white.opacity(0.12), location: 0.4),
                    .init(color: Color.white.opacity(0.04), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                stops: [
                    .init(color: Color.white.opacity(0.95), location: 0.0),
                    .init(color: Color.black.opacity(0.06), location: 0.5),
                    .init(color: Color.black.opacity(0.12), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    public func glassMaterialFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.65)
    }

    public func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black.opacity(0.55) : Color.black.opacity(0.08)
    }

    public func progressHighlight(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }

    public func specularBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.10)
    }

    public func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.12) : Color.white
    }

    public func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentVariant.darkTint : accentVariant.lightTint
    }
}
