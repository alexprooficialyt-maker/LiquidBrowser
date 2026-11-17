import SwiftUI

// MARK: - LiquidIconType Enum (48 Handcrafted Vector Icons)

public enum LiquidIconType: String, CaseIterable, Codable, Sendable {
    // 1. Navegación Safari
    case back
    case forward
    case reload
    case stop
    case home

    // 2. Barra de Búsqueda y Acciones
    case search
    case tabs
    case newTab
    case toolsMenu
    case close
    case share
    case download

    // 3. Motores de Búsqueda
    case googleSearch
    case duckDuckGoSearch
    case braveSearch
    case ecosiaSearch

    // 4. Seguridad, SSL y Anti-Rastreo
    case lockSSL
    case unlockSSL
    case warningSSL
    case shieldBlocker
    case shieldActive

    // 5. Biometría y Autenticación
    case faceID
    case touchID
    case pinPad
    case keyPassword
    case vault

    // 6. Espacios y Carpetas
    case spaceFolder
    case spaceWork
    case spaceStudy
    case spaceCode
    case spacePrivate
    case spaceStar
    case pin
    case unpin
    case moveSpace
    case editPencil
    case trash

    // 7. Herramientas y Ajustes
    case readerMode
    case qrCode
    case pdfExport
    case history
    case bookmarks
    case downloads
    case settings
    case palette
    case globeLanguage
    case resetFactory
    case checkmark
    case chevronRight
    case chevronDown

    // 8. Perfiles
    case userProfile
    case briefcase
    case graduationCap
}

// MARK: - Handcrafted Bézier Shapes Implementation

public struct LiquidIconShape: Shape {
    public let type: LiquidIconType

    public init(_ type: LiquidIconType) {
        self.type = type
    }

    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        switch type {
        // --- NAVEGACIÓN ---
        case .back:
            p.move(to: CGPoint(x: w * 0.65, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.80))

        case .forward:
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.80))

        case .reload:
            p.addArc(center: CGPoint(x: w * 0.5, y: h * 0.5), radius: w * 0.34, startAngle: .degrees(-45), endAngle: .degrees(250), clockwise: false)
            p.move(to: CGPoint(x: w * 0.70, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.36))

        case .stop:
            p.move(to: CGPoint(x: w * 0.30, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.70))
            p.move(to: CGPoint(x: w * 0.70, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.70))

        case .home:
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.45))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.45))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.82))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.40, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.40, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.60, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.60, y: h * 0.82))

        // --- BARRA INFERIOR SAFARI ---
        case .search:
            p.addEllipse(in: CGRect(x: w * 0.20, y: h * 0.20, width: w * 0.46, height: h * 0.46))
            p.move(to: CGPoint(x: w * 0.54, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.80))

        case .tabs:
            p.addRoundedRect(in: CGRect(x: w * 0.18, y: h * 0.28, width: w * 0.50, height: h * 0.50), cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.64))

        case .newTab:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))

        case .toolsMenu:
            // Icono de controles y herramientas de página (3 barras con deslizadores estilo Apple)
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.50))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.70))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.70))
            // Círculos de deslizadores
            p.addEllipse(in: CGRect(x: w * 0.32, y: h * 0.24, width: w * 0.12, height: h * 0.12))
            p.addEllipse(in: CGRect(x: w * 0.58, y: h * 0.44, width: w * 0.12, height: h * 0.12))
            p.addEllipse(in: CGRect(x: w * 0.40, y: h * 0.64, width: w * 0.12, height: h * 0.12))

        case .close:
            p.move(to: CGPoint(x: w * 0.26, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.74))
            p.move(to: CGPoint(x: w * 0.74, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.74))

        case .share:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.60))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.32))
            // Bandeja
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.46))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.80))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.80))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.46))

        case .download:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.62))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.46))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.62))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.46))
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.78))

        // --- MOTORES DE BÚSQUEDA ---
        case .googleSearch:
            p.addArc(center: CGPoint(x: w * 0.5, y: h * 0.5), radius: w * 0.32, startAngle: .degrees(-45), endAngle: .degrees(225), clockwise: true)
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))

        case .duckDuckGoSearch:
            p.addEllipse(in: CGRect(x: w * 0.18, y: h * 0.18, width: w * 0.64, height: h * 0.64))
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.44))

        case .braveSearch:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.15))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.85))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.30))
            p.closeSubpath()

        case .ecosiaSearch:
            p.addEllipse(in: CGRect(x: w * 0.28, y: h * 0.22, width: w * 0.44, height: h * 0.44))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.80))

        // --- SEGURIDAD Y SSL ---
        case .lockSSL:
            p.addRoundedRect(in: CGRect(x: w * 0.24, y: h * 0.44, width: w * 0.52, height: h * 0.42), cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.30))
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.30), radius: w * 0.16, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.44))
            // Bocallave
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.72))

        case .unlockSSL:
            p.addRoundedRect(in: CGRect(x: w * 0.24, y: h * 0.44, width: w * 0.52, height: h * 0.42), cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.26))
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.26), radius: w * 0.16, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.32))

        case .warningSSL:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.15, y: h * 0.82))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.60))
            p.addEllipse(in: CGRect(x: w * 0.47, y: h * 0.68, width: w * 0.06, height: h * 0.06))

        case .shieldBlocker:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.14))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.54))
            p.addCurve(
                to: CGPoint(x: w * 0.50, y: h * 0.86),
                control1: CGPoint(x: w * 0.82, y: h * 0.72),
                control2: CGPoint(x: w * 0.65, y: h * 0.82)
            )
            p.addCurve(
                to: CGPoint(x: w * 0.18, y: h * 0.54),
                control1: CGPoint(x: w * 0.35, y: h * 0.82),
                control2: CGPoint(x: w * 0.18, y: h * 0.72)
            )
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.26))
            p.closeSubpath()

        case .shieldActive:
            p = LiquidIconShape(.shieldBlocker).path(in: rect)
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.62))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.38))

        // --- BIOMETRÍA Y AUTENTICACIÓN ---
        case .faceID:
            // Esquinas exteriores
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.22))

            p.move(to: CGPoint(x: w * 0.66, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.34))

            p.move(to: CGPoint(x: w * 0.80, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.78))

            p.move(to: CGPoint(x: w * 0.34, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.66))

            // Ojos
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.44))
            p.move(to: CGPoint(x: w * 0.62, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.44))

            // Nariz
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.42))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.56))

            // Sonrisa
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.64))
            p.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.64), control: CGPoint(x: w * 0.50, y: h * 0.72))

        case .touchID:
            // Huella digital estilizada
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.54), radius: w * 0.30, startAngle: .degrees(190), endAngle: .degrees(-10), clockwise: false)
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.54), radius: w * 0.20, startAngle: .degrees(190), endAngle: .degrees(-10), clockwise: false)
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.54), radius: w * 0.10, startAngle: .degrees(190), endAngle: .degrees(-10), clockwise: false)
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.80))

        case .pinPad:
            for row in 0..<3 {
                for col in 0..<3 {
                    let cx = w * (0.30 + CGFloat(col) * 0.20)
                    let cy = h * (0.30 + CGFloat(row) * 0.20)
                    p.addEllipse(in: CGRect(x: cx - 2, y: cy - 2, width: 4, height: 4))
                }
            }

        case .keyPassword:
            p.addEllipse(in: CGRect(x: w * 0.20, y: h * 0.24, width: w * 0.34, height: h * 0.34))
            p.move(to: CGPoint(x: w * 0.48, y: h * 0.48))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.78))
            p.move(to: CGPoint(x: w * 0.66, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.56))

        case .vault:
            p.addRoundedRect(in: CGRect(x: w * 0.18, y: h * 0.20, width: w * 0.64, height: h * 0.60), cornerSize: CGSize(width: 6, height: 6))
            p.addEllipse(in: CGRect(x: w * 0.40, y: h * 0.40, width: w * 0.20, height: h * 0.20))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.35))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.65))
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.50))

        // --- ESPACIOS Y PESTAÑAS ---
        case .spaceFolder:
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.48, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.16, y: h * 0.78))
            p.closeSubpath()

        case .spaceWork:
            p = LiquidIconShape(.spaceFolder).path(in: rect)
            p.move(to: CGPoint(x: w * 0.42, y: h * 0.52))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.52))

        case .spaceStudy:
            p = LiquidIconShape(.spaceFolder).path(in: rect)
            p.addEllipse(in: CGRect(x: w * 0.44, y: h * 0.50, width: w * 0.12, height: h * 0.12))

        case .spaceCode:
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.62))
            p.move(to: CGPoint(x: w * 0.62, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.62))
            p.move(to: CGPoint(x: w * 0.56, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.68))

        case .spacePrivate:
            p = LiquidIconShape(.spaceFolder).path(in: rect)
            p.addEllipse(in: CGRect(x: w * 0.46, y: h * 0.54, width: w * 0.08, height: h * 0.08))

        case .spaceStar:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.59, y: h * 0.36))
            p.addLine(to: CGPoint(x: w * 0.79, y: h * 0.39))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.53))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.73))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.64))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.73))
            p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.53))
            p.addLine(to: CGPoint(x: w * 0.21, y: h * 0.39))
            p.addLine(to: CGPoint(x: w * 0.41, y: h * 0.36))
            p.closeSubpath()

        case .pin:
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.48))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.48))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.82))

        case .unpin:
            p = LiquidIconShape(.pin).path(in: rect)
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.78))

        case .moveSpace:
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))
            p.move(to: CGPoint(x: w * 0.62, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.66))

        case .editPencil:
            p.move(to: CGPoint(x: w * 0.68, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.72))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.62))
            p.closeSubpath()

        case .trash:
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.30))
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.30))
            p.move(to: CGPoint(x: w * 0.28, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.30))

        // --- HERRAMIENTAS Y AJUSTES ---
        case .readerMode:
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.48, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.48, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.76))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.52, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.52, y: h * 0.76))
            p.closeSubpath()

        case .qrCode:
            p.addRect(CGRect(x: w * 0.20, y: h * 0.20, width: w * 0.24, height: h * 0.24))
            p.addRect(CGRect(x: w * 0.56, y: h * 0.20, width: w * 0.24, height: h * 0.24))
            p.addRect(CGRect(x: w * 0.20, y: h * 0.56, width: w * 0.24, height: h * 0.24))
            p.move(to: CGPoint(x: w * 0.56, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.80))

        case .pdfExport:
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.82))
            p.closeSubpath()

        case .history:
            p.addEllipse(in: CGRect(x: w * 0.18, y: h * 0.18, width: w * 0.64, height: h * 0.64))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.50))

        case .bookmarks:
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.64))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.82))
            p.closeSubpath()

        case .downloads:
            p = LiquidIconShape(.download).path(in: rect)

        case .settings:
            p.addEllipse(in: CGRect(x: w * 0.36, y: h * 0.36, width: w * 0.28, height: h * 0.28))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.24))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.84))
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.50))
            p.move(to: CGPoint(x: w * 0.76, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.50))

        case .palette:
            p.addEllipse(in: CGRect(x: w * 0.16, y: h * 0.18, width: w * 0.68, height: h * 0.64))
            p.addEllipse(in: CGRect(x: w * 0.32, y: h * 0.34, width: 4, height: 4))
            p.addEllipse(in: CGRect(x: w * 0.50, y: h * 0.28, width: 4, height: 4))
            p.addEllipse(in: CGRect(x: w * 0.64, y: h * 0.40, width: 4, height: 4))

        case .globeLanguage:
            p.addEllipse(in: CGRect(x: w * 0.16, y: h * 0.16, width: w * 0.68, height: h * 0.68))
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.50))
            p.addEllipse(in: CGRect(x: w * 0.30, y: h * 0.16, width: w * 0.40, height: h * 0.68))

        case .resetFactory:
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.50))
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.50), radius: w * 0.32, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: false)
            p.move(to: CGPoint(x: w * 0.12, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.40))

        case .checkmark:
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.52))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.72))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))

        case .chevronRight:
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.24))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.76))

        case .chevronDown:
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.62))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.38))

        // --- PERFILES ---
        case .userProfile:
            p.addEllipse(in: CGRect(x: w * 0.32, y: h * 0.18, width: w * 0.36, height: h * 0.36))
            p.move(to: CGPoint(x: w * 0.18, y: h * 0.82))
            p.addCurve(
                to: CGPoint(x: w * 0.82, y: h * 0.82),
                control1: CGPoint(x: w * 0.20, y: h * 0.58),
                control2: CGPoint(x: w * 0.80, y: h * 0.58)
            )

        case .briefcase:
            p.addRoundedRect(in: CGRect(x: w * 0.18, y: h * 0.34, width: w * 0.64, height: h * 0.48), cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.34))

        case .graduationCap:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.16, y: h * 0.38))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.30, y: h * 0.46))
            p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.68))
            p.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.68), control: CGPoint(x: w * 0.50, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.46))
        }

        return p
    }
}

// MARK: - LiquidIconView (Universal Vector Icon View with Stroke & LineWidth Fallback)

public struct LiquidIconView: View {
    public let type: LiquidIconType
    public let size: CGFloat
    public let color: Color?
    public let strokeWidth: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ type: LiquidIconType,
        size: CGFloat = 20,
        color: Color? = nil,
        strokeWidth: CGFloat = 1.5,
        lineWidth: CGFloat? = nil
    ) {
        self.type = type
        self.size = size
        self.color = color
        self.strokeWidth = lineWidth ?? strokeWidth
    }

    public var body: some View {
        let resolvedColor = color ?? ThemeManager.shared.textPrimary(for: colorScheme)

        LiquidIconShape(type)
            .stroke(
                resolvedColor,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Animated Micro-Interactions

// 1. Escudo Anti-Espías con Pulso Suave cuando bloquea
public struct AnimatedShieldIcon: View {
    public var isBlocking: Bool
    public var blockedCount: Int
    public var size: CGFloat = 22
    @Environment(\.colorScheme) private var colorScheme
    @State private var pulseScale: CGFloat = 1.0

    public init(isBlocking: Bool, blockedCount: Int = 0, size: CGFloat = 22) {
        self.isBlocking = isBlocking
        self.blockedCount = blockedCount
        self.size = size
    }

    public var body: some View {
        ZStack {
            LiquidIconView(.shieldActive, size: size, color: ThemeManager.shared.textPrimary(for: colorScheme))
                .scaleEffect(pulseScale)

            if isBlocking {
                Circle()
                    .stroke(ThemeManager.shared.accent(for: colorScheme), lineWidth: 1.0)
                    .frame(width: size * 1.3, height: size * 1.3)
                    .scaleEffect(pulseScale)
                    .opacity(2.0 - pulseScale)
            }
        }
        .onChange(of: blockedCount) { _, _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                pulseScale = 1.25
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    pulseScale = 1.0
                }
            }
        }
    }
}

// 2. Candado SSL Animado con Rotación Mecánica
public struct AnimatedPadlockIcon: View {
    public var isSecure: Bool
    public var size: CGFloat = 18
    @Environment(\.colorScheme) private var colorScheme

    public init(isSecure: Bool, size: CGFloat = 18) {
        self.isSecure = isSecure
        self.size = size
    }

    public var body: some View {
        ZStack {
            if isSecure {
                LiquidIconView(.lockSSL, size: size, color: ThemeManager.shared.textPrimary(for: colorScheme))
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            } else {
                LiquidIconView(.warningSSL, size: size, color: Color(red: 0.95, green: 0.40, blue: 0.10))
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
        }
        .animation(LiquidAnimation.interactiveSpring, value: isSecure)
    }
}

// 3. Icono de Recarga con Rotación Fluida
public struct AnimatedReloadIcon: View {
    public var isLoading: Bool
    public var size: CGFloat = 20
    @Environment(\.colorScheme) private var colorScheme
    @State private var angle: Double = 0

    public init(isLoading: Bool, size: CGFloat = 20) {
        self.isLoading = isLoading
        self.size = size
    }

    public var body: some View {
        LiquidIconView(isLoading ? .stop : .reload, size: size, color: ThemeManager.shared.textPrimary(for: colorScheme))
            .rotationEffect(.degrees(angle))
            .onChange(of: isLoading) { _, loading in
                if loading {
                    withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                        angle = 360
                    }
                } else {
                    withAnimation(LiquidAnimation.interactiveSpring) {
                        angle = 0
                    }
                }
            }
    }
}

// 4. Icono Biométrico con Pulso de Escaneo
public struct AnimatedBiometricIcon: View {
    public var type: LABiometryType
    public var isScanning: Bool
    public var size: CGFloat = 48
    @Environment(\.colorScheme) private var colorScheme
    @State private var scanOffset: CGFloat = -18

    public init(type: LABiometryType, isScanning: Bool = false, size: CGFloat = 48) {
        self.type = type
        self.isScanning = isScanning
        self.size = size
    }

    public var body: some View {
        ZStack {
            LiquidIconView(
                type == .faceID ? .faceID : .touchID,
                size: size,
                color: ThemeManager.shared.textPrimary(for: colorScheme),
                strokeWidth: 2.0
            )

            if isScanning {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, ThemeManager.shared.textPrimary(for: colorScheme).opacity(0.6), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size, height: 4)
                    .offset(y: scanOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            scanOffset = 18
                        }
                    }
            }
        }
        .frame(width: size, height: size)
    }
}
