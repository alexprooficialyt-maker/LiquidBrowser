import SwiftUI

// MARK: - Paleta completa LiquidBrowser

struct AppColors {

    // Glass surfaces — capas translúcidas
    static let glassFill        = Color.white.opacity(0.11)
    static let glassFillDark    = Color.white.opacity(0.06)
    static let glassBorderTop   = Color.white.opacity(0.52)
    static let glassBorderBot   = Color.white.opacity(0.10)
    static let glassShadow      = Color.black.opacity(0.22)
    static let glassInnerGlow   = Color.white.opacity(0.07)

    // Gradiente oscuro principal (fondo de onboarding, pantallas secundarias)
    static let bgDarkTop        = Color(red: 0.04, green: 0.04, blue: 0.10)
    static let bgDarkMid        = Color(red: 0.06, green: 0.04, blue: 0.16)
    static let bgDarkBot        = Color(red: 0.02, green: 0.08, blue: 0.14)

    // Overlay de transición negro→transparente (para ocultar/revelar contenido)
    static func fadeOverlay(from: Edge) -> LinearGradient {
        let colors: [Color] = [.black.opacity(0.85), .clear]
        switch from {
        case .bottom: return LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top)
        case .top:    return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
        case .leading:return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        default:      return LinearGradient(colors: colors, startPoint: .trailing, endPoint: .leading)
        }
    }

    // Estado
    static let secure      = Color(red: 0.18, green: 0.80, blue: 0.47)
    static let insecure    = Color(red: 1.00, green: 0.62, blue: 0.00)
    static let danger      = Color(red: 1.00, green: 0.27, blue: 0.27)
    static let privateMode = Color(red: 0.48, green: 0.24, blue: 0.80)

    // Texto
    static let primary   = Color.primary
    static let secondary = Color.secondary

    static func accent(_ hex: String) -> Color { Color(hex: hex) ?? .blue }
}

// MARK: - Hex → Color

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                   .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: h).scanHexInt64(&rgb) else { return nil }
        self.init(
            red:   Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >>  8) / 255,
            blue:  Double( rgb & 0x0000FF)         / 255
        )
    }

    var toHex: String {
        let c = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        return String(format: "#%02X%02X%02X",
                      Int(c[0]*255), Int(c[1]*255), Int(c[2]*255))
    }
}
